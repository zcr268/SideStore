//
//  AuthManager.swift
//  SideStore
//
//  Created by Magesh K on 1/8/26.
//  Copyright © 2026 SideStore. All rights reserved.
//

@preconcurrency import UIKit
import Foundation
import SideSign
import CoreData

public final class AuthManager: @unchecked Sendable {
    public static let shared = AuthManager()
    
    private var portalService: DeveloperPortalAuthService {
        DeveloperPortalService.shared as! DeveloperPortalAuthService
    }
    
    private init() {}
    
    public var team: ALTTeam?
    public var session: ALTAppleAPISession?

    public var isAuthenticated: Bool {
        let hasEmail = Keychain.shared.appleIDEmailAddress != nil
        let hasPassword = Keychain.shared.appleIDPassword != nil
        let hasToken = Keychain.shared.appleIDXcodeToken != nil
        return hasEmail && (hasPassword || hasToken)
    }
    
    public var currentAppleID: String? {
        get { Keychain.shared.appleIDEmailAddress }
        set { Keychain.shared.appleIDEmailAddress = newValue }
    }
    
    public var password: String? {
        get { Keychain.shared.appleIDPassword }
        set { Keychain.shared.appleIDPassword = newValue }
    }
    
    public var adsid: String? {
        get { Keychain.shared.appleIDAdsid }
        set { Keychain.shared.appleIDAdsid = newValue }
    }
    
    public var xcodeToken: String? {
        get { Keychain.shared.appleIDXcodeToken }
        set { Keychain.shared.appleIDXcodeToken = newValue }
    }
    
    public var hasStoredPassword: Bool {
        return Keychain.shared.appleIDPassword != nil
    }
    
    public var hasStoredXcodeToken: Bool {
        return Keychain.shared.appleIDXcodeToken != nil
    }
    
    public func signOut(keepCertificate: Bool = false, keepAnisetteData: Bool = true) {
        self.session = nil
        self.team = nil
        if !keepCertificate {
            debugLog("[AuthManager] Clearing signing certificate in cert manager and keychain.")
            CertificateManager.shared.clearActiveCertificate()
            debugLog("[AuthManager] Cleared signing certificate in cert manager and keychain.")

        } else {
            debugLog("[AuthManager] Preserved signing certificate in cert manager and keychain.")
        }
        debugLog("[AuthManager] Clearing account and team info in database.")
        DatabaseManager.shared.deactivateActiveAccountAndTeam()
        debugLog("[AuthManager] Cleared account and team info in database.")

        debugLog("[AuthManager] Clearing sign-in info from keychain.")
        Keychain.shared.clearSignInInfo(keepAnisetteData: keepAnisetteData)
        debugLog("[AuthManager] Cleared sign-in info from keychain.")

        AnisetteDataManager.shared.clearCache()
    }
    
    public struct AuthenticatedSession: Sendable {
        public let team: ALTTeam
        public let session: ALTAppleAPISession
        
        public init(team: ALTTeam, session: ALTAppleAPISession) {
            self.team = team
            self.session = session
        }
    }
    
    @discardableResult
    public func getAuthenticatedSession() async throws -> AuthenticatedSession {
        return try await TaskChainCoalescerWithProgress.shared.coalesce(key: "apple_auth") { reportProgress in
            // 1. Check for valid in-memory cached session & team
            if var session = self.session, let team = self.team {
                session.anisetteData = try await AnisetteProvider.fetch()
                self.session = session
                
                debugLog("[AuthManager] Using cached session and team ('\(team.name)').")
                reportProgress(100)
                return AuthenticatedSession(team: team, session: session)
            }
            
            // 2. Perform direct token-based session resolution
            if let silentResult = try await self.resolveSessionSilently(reportProgress: reportProgress) {
                reportProgress(100)
                return silentResult
            }
            
            // 3. If session cannot be resolved silently, fail fast
            debugLog("[AuthManager] No active or valid session found.")
            throw OperationError.notAuthenticated
        }
    }
    
    private func resolveSessionSilently(reportProgress: @escaping @Sendable (Int64) -> Void) async throws -> AuthenticatedSession? {
        guard let adsid = self.adsid, let xcodeToken = self.xcodeToken else {
            return nil
        }

        verboseLog("[AuthManager] Resolving session via tokens...")
        do {
            let anisetteData = try await AnisetteProvider.fetch()
            let xcodeVersion = await AnisetteConfigManager.shared.resolvedXcodeVersion()

            let (_, session) = try await self.authenticateWithToken(
                adsid: adsid,
                xcodeToken: xcodeToken, 
                anisetteData: anisetteData, 
                xcodeVersion: xcodeVersion
            )
            
            self.session = session
            
            // Resolve active team from CoreData
            let team = try await self.resolveActiveTeam()
            self.team = team
            
            debugLog("[AuthManager] Successfully resolved session and team ('\(team.name)').")
            return AuthenticatedSession(team: team, session: session)
        } catch {
            debugLog("[AuthManager] Silent token session resolution failed: \(error)")
            return nil
        }
    }

    private func resolveActiveTeam() async throws -> ALTTeam {
        try await DatabaseManager.shared.persistentContainer.performBackgroundTask { context in
            guard let dbTeam = DatabaseManager.shared.activeTeam(in: context) else {
                throw OperationError.notAuthenticated
            }
            return ALTTeam(identifier: dbTeam.identifier, name: dbTeam.name, type: dbTeam.type)
        }
    }
    
    @discardableResult
    func signIn(
        presentingViewController: UIViewController? = nil,
        skipDeviceRegistration: Bool = false,
        skipCertificateProvisioning: Bool = false
    ) async throws -> SignInResult {
        let dbBackgroundContext = DatabaseManager.shared.persistentContainer.newBackgroundContext()
        let signInFlowHandler = SignInFlowHandler(presentingViewController: presentingViewController)
        let context = StandaloneOperationContext(
            steps: .signIn,
            dbBackgroundContext: dbBackgroundContext
        )
        
        let signInOperation = try SignInOperation(
            context: context,
            signInHandler: signInFlowHandler,
            anisetteServerHandler: signInFlowHandler,
            skipDeviceRegistration: skipDeviceRegistration,
            skipCertificateProvisioning: skipCertificateProvisioning
        )
        return try await signInOperation.execute()
    }
    
    
    // Developer Portal Operations
    public func signIn(appleID: String, 
                       password: String, 
                       anisetteData: ALTAnisetteData, 
                       xcodeVersion: String, 
                       machinePassword: String? = nil,
                       accountRepairHandler: DeveloperPortal.AccountRepairHandler = DeveloperPortal.defaultAccountRepairHandler,
                       verificationHandler: DeveloperPortal.VerificationHandler?) async throws -> (ALTAccount, ALTAppleAPISession) 
    {
        return try await self.portalService.signIn(
            appleID: appleID, 
            password: password, 
            anisetteData: anisetteData, 
            xcodeVersion: xcodeVersion, 
            machinePassword: machinePassword,
            accountRepairHandler: accountRepairHandler, 
            verificationHandler: verificationHandler
        )
    }
    
    public func authenticateWithToken(adsid: String,
                                      xcodeToken: String,
                                      anisetteData: ALTAnisetteData,
                                      xcodeVersion: String) async throws -> (ALTAccount, ALTAppleAPISession)
    {
        return try await self.portalService.authenticateWithToken(
            adsid: adsid,
            xcodeToken: xcodeToken,
            anisetteData: anisetteData,
            xcodeVersion: xcodeVersion
        )
    }
}

fileprivate extension DatabaseManager {
    //TODO: this is not clean, but for now this should be fine, ie we should later make this proper async instead of blocking
    func deactivateActiveAccountAndTeam() {
        guard self.isStarted else {
            debugLog("[AuthManager] DatabaseManager is not started. Skipping CoreData active account/team deactivation.")
            return
        }
        let bgContext = self.persistentContainer.newBackgroundContext()
        bgContext.performAndWait {
            if let account = self.activeAccount(in: bgContext) {
                account.isActiveAccount = false
            }
            if let team = self.activeTeam(in: bgContext) {
                team.isActiveTeam = false
            }
            do {
                try bgContext.save()
            } catch {
                debugLog("[AuthManager] Failed to save CoreData context when deactivating active account and team: \(error)")
            }
        }
        
        self.viewContext.performAndWait {
            self.viewContext.processPendingChanges()
            self.viewContext.refreshAllObjects()
        }
    }
}
