//
//  AuthenticationOperation.swift
//  AltStore
//
//  Created by Riley Testut on 6/5/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

@preconcurrency import UIKit
import Foundation
import CoreData
import SideSign

struct AuthenticationResult {
    let team: ALTTeam
    let session: ALTAppleAPISession
}

final class AuthenticationOperation: BaseStandaloneOperation<StandaloneOperationContext, AuthenticationResult>, @unchecked Sendable {

    override init(context: StandaloneOperationContext) throws {
        try super.init(context: context)
        self.debugLog("[AuthenticationOperation] Initialized")
    }

    private func getAnisetteData() async throws -> ALTAnisetteData {
        try await AnisetteProvider.fetch()
    }
    
    // Main Pipeline Execution
    override func execute(parentProgress: Progress?) async throws -> AuthenticationResult {
        let startTime = CFAbsoluteTimeGetCurrent()
        debugLog("[AuthenticationOperation] execute() started")
        defer {
            let elapsed = CFAbsoluteTimeGetCurrent() - startTime
            debugLog("[AuthenticationOperation] execute() took: \(String(format: "%.3fs", elapsed))")
        }
        try await super.executePreconditionCheck(parentProgress: parentProgress)

        let authResult: AuthenticationResult
        do {
            authResult = try await TaskChainCoalescerWithProgress.shared.coalesce(
                key: "apple_auth",
                onProgress: { [weak self] progress in
                    self?.setProgress(progress)
                }
            ) { [weak self] reportProgress -> AuthenticationResult in
                guard let self = self else { throw OperationError.cancelled }
                
                // 1. Check for valid in-memory cached session
                if var session = AuthManager.shared.session,
                   let team = AuthManager.shared.team
                {
                    session.anisetteData = try await self.getAnisetteData()
                    
                    self.debugLog("[AuthenticationOperation] Using cached session and team ('\(team.name)').")
                    reportProgress(100)
                    return AuthenticationResult(
                        team: team, 
                        session: session
                    )
                }
                
                // 2. Perform direct token-based session resolution
                if let silentResult = try await self.resolveSessionSilently(reportProgress: reportProgress) {
                    reportProgress(100)
                    return silentResult
                }
                
                // 3. If session cannot be resolved silently, fail fast
                self.debugLog("[AuthenticationOperation] No active or valid session found.")
                throw OperationError.notAuthenticated
            }
        } catch {
            throw error
        }
        
        if let authContext = self.context as? AuthenticatedOperationContext {
            authContext.team = authResult.team
            authContext.session = authResult.session
        }

        self.setProgress(100)
        return authResult
    }
    
    private func resolveSessionSilently(reportProgress: @escaping @Sendable (Int64) -> Void) async throws -> AuthenticationResult? {
        // Silent session resolution strictly using Keychain Xcode Token
        guard let adsid = AuthManager.shared.adsid, 
              let xcodeToken = AuthManager.shared.xcodeToken 
        else {
            return nil
        }

        self.verboseLog("[AuthenticationOperation] Resolving session via tokens...")
        do {
            let anisetteData = try await self.getAnisetteData()
            let xcodeVersion = await AnisetteConfigManager.shared.resolvedXcodeVersion()

            let (_, session) = try await AuthManager.shared.authenticateWithToken(
                adsid: adsid,
                xcodeToken: xcodeToken, 
                anisetteData: anisetteData, 
                xcodeVersion: xcodeVersion
            )
            
            AuthManager.shared.session = session
            if let authContext = self.context as? AuthenticatedOperationContext {
                authContext.session = session
            }
            
            // Resolve active team from CoreData
            let team = try await self.resolveActiveTeam()
            AuthManager.shared.team = team
            if let authContext = self.context as? AuthenticatedOperationContext {
                authContext.team = team
            }
            
            self.debugLog("[AuthenticationOperation] Successfully resolved session and team ('\(team.name)').")
            return AuthenticationResult(
                team: team,
                session: session
            )
        } catch {
            self.debugLog("[AuthenticationOperation] Silent token session resolution failed: \(error)")
            return nil
        }
    }

    private func resolveActiveTeam() async throws -> ALTTeam {
        let dbContext = self.context.dbBackgroundContext ?? DatabaseManager.shared.viewContext
        let activeTeam = await dbContext.perform {
            if let dbTeam = DatabaseManager.shared.activeTeam(in: dbContext) {
                return ALTTeam(identifier: dbTeam.identifier, name: dbTeam.name, type: dbTeam.type)
            }
            return nil
        }
        guard let activeTeam = activeTeam else {
            throw OperationError.notAuthenticated
        }
        return activeTeam
    }
}

enum AnisetteProvider {
    static func fetch(handler: AnisetteServerHandler? = nil) async throws -> ALTAnisetteData {
        if UserDefaults.standard.useOnDeviceAnisette {
            debugLog("[AuthenticationOperation] Fetching anisette via On-Device Anisette (ODA)...")
            return try await OnDeviceAnisetteManager.shared.fetchAnisetteData()
        } else {
            debugLog("[AuthenticationOperation] Fetching anisette via remote server...")
            return try await fetchRemote(handler: handler)
        }
    }

    private static func fetchRemote(handler: AnisetteServerHandler? = nil) async throws -> ALTAnisetteData {
        let serverUrlStrings = await AnisetteServersManager.shared.getActiveServerURLs()
        let servers = serverUrlStrings.compactMap { URL(string: $0) }
        guard !servers.isEmpty else {
            throw AnisetteError.noServersConfigured
        }

        let lastServer = UserDefaults.standard.menuAnisetteURL
        let startIndex = servers.firstIndex(where: { $0.absoluteString == lastServer }) ?? 0

        let provider = SideSign.AnisetteDataManager.shared
        let existingBlob = AnisetteConfigManager.shared.anisetteAdiBlob.flatMap { Data(base64Encoded: $0) }
        let identifier = await AnisetteConfigManager.shared.resolveDeviceIdentifier()

        let (anisetteData, newAdiBlob) = try await provider.fetchAnisetteDataWithFailover(
            servers: UserDefaults.standard.disableAnisetteRotation ? [servers[startIndex]] : servers,
            startIndex: startIndex,
            identifier: identifier,
            existingAdiBlob: existingBlob,
            onError: { error in
                if let anisetteError = error as? SideSign.AnisetteError,
                   case .outdatedV1Server(let serverURL, _) = anisetteError {
                    if UserDefaults.standard.defaultServerURL == serverURL.absoluteString {
                        return true
                    }
                    if let handler = handler {
                        let shouldContinue = try await handler.warnOutdatedAnisetteServer()
                        if shouldContinue {
                            UserDefaults.standard.defaultServerURL = serverURL.absoluteString
                        }
                        return shouldContinue
                    }
                }
                return false
            },
            onSuccess: { successfulServer in
                UserDefaults.standard.menuAnisetteURL = successfulServer.absoluteString
                debugLog("[AuthenticationOperation] Successfully fetched Anisette data from \(successfulServer.absoluteString)")
            }
        )

        if let freshBlob = newAdiBlob {
            AnisetteConfigManager.shared.anisetteAdiBlob = freshBlob.base64EncodedString()
        }

        return anisetteData
    }
}
