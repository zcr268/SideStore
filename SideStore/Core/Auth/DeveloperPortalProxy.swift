//
//  DeveloperPortalProxy.swift
//  SideStore
//
//  Created by Magesh K on 2026-06-29.
//  Copyright © 2026 SideStore. All rights reserved.
//

@preconcurrency import UIKit
import SideSign

public class DeveloperPortalProxy {
    public static let shared: DeveloperPortalProxy = DeveloperPortalProxyWithAuth()
    
    fileprivate init() {}
    
    private func getSession() async throws -> AuthManager.AuthenticatedSession {
        try await AuthManager.shared.getAuthenticatedSession()
    }
    
    public func fetchTeams(for account: ALTAccount) async throws -> [ALTTeam] {
        let auth = try await self.getSession()
        return try await ALTAppleAPI.shared.fetchTeams(for: account, session: auth.session)
    }
    
    public func fetchCertificates(team: ALTTeam? = nil) async throws -> [ALTX509Certificate] {
        let auth = try await self.getSession()
        return try await ALTAppleAPI.shared.fetchCertificates(for: team ?? auth.team, session: auth.session)
    }
    
    @discardableResult
    public func createCertificate(machineName: String, team: ALTTeam? = nil) async throws -> ALTCertificate {
        let auth = try await self.getSession()
        return try await ALTAppleAPI.shared.addCertificate(machineName: machineName, to: team ?? auth.team, session: auth.session)
    }
    
    @discardableResult
    public func revokeCertificate(_ certificate: ALTX509Certificate, team: ALTTeam? = nil) async throws -> Bool {
        let auth = try await self.getSession()
        return try await ALTAppleAPI.shared.revokeCertificate(certificate, for: team ?? auth.team, session: auth.session)
    }
    
    public func fetchDevices(for team: ALTTeam? = nil, types: ALTDeviceType = .all) async throws -> [ALTDevice] {
        let auth = try await self.getSession()
        return try await ALTAppleAPI.shared.fetchDevices(for: team ?? auth.team, types: types, session: auth.session)
    }
    
    @discardableResult
    public func registerDevice(name: String, identifier: String, type: ALTDeviceType = .iphone, team: ALTTeam? = nil) async throws -> ALTDevice {
        let auth = try await self.getSession()
        return try await ALTAppleAPI.shared.registerDevice(name: name, identifier: identifier, type: type, team: team ?? auth.team, session: auth.session)
    }

    @discardableResult
    public func updateDevice(_ device: ALTDevice, team: ALTTeam? = nil) async throws -> ALTDevice {
        let auth = try await self.getSession()
        return try await ALTAppleAPI.shared.updateDevice(device, team: team ?? auth.team, session: auth.session)
    }

    @discardableResult
    public func disableDevice(_ device: ALTDevice, team: ALTTeam? = nil) async throws -> ALTDevice {
        let auth = try await self.getSession()
        return try await ALTAppleAPI.shared.disableDevice(device, team: team ?? auth.team, session: auth.session)
    }

    @discardableResult
    public func deleteDevice(_ device: ALTDevice, team: ALTTeam? = nil) async throws -> Bool {
        let auth = try await self.getSession()
        return try await ALTAppleAPI.shared.deleteDevice(device, team: team ?? auth.team, session: auth.session)
    }

    public func fetchAppIDs(team: ALTTeam? = nil) async throws -> [ALTAppID] {
        let auth = try await self.getSession()
        return try await ALTAppleAPI.shared.fetchAppIDs(for: team ?? auth.team, session: auth.session)
    }

    public func fetchAppIDs(for team: ALTTeam) async throws -> [ALTAppID] {
        try await self.fetchAppIDs(team: team)
    }

    @discardableResult
    public func addAppID(name: String, bundleIdentifier: String, team: ALTTeam? = nil) async throws -> ALTAppID {
        let auth = try await self.getSession()
        return try await ALTAppleAPI.shared.addAppID(withName: name, bundleIdentifier: bundleIdentifier, team: team ?? auth.team, session: auth.session)
    }

    @discardableResult
    public func updateAppID(_ appID: ALTAppID, team: ALTTeam? = nil) async throws -> ALTAppID {
        let auth = try await self.getSession()
        return try await ALTAppleAPI.shared.updateAppID(appID, team: team ?? auth.team, session: auth.session)
    }

    @discardableResult
    public func deleteAppID(_ appID: ALTAppID, team: ALTTeam? = nil) async throws -> Bool {
        let auth = try await self.getSession()
        return try await ALTAppleAPI.shared.deleteAppID(appID, for: team ?? auth.team, session: auth.session)
    }

    @discardableResult
    public func deleteAppID(_ appID: ALTAppID, for team: ALTTeam) async throws -> Bool {
        try await self.deleteAppID(appID, team: team)
    }

    public func fetchAppGroups(team: ALTTeam? = nil) async throws -> [ALTAppGroup] {
        let auth = try await self.getSession()
        return try await ALTAppleAPI.shared.fetchAppGroups(for: team ?? auth.team, session: auth.session)
    }

    public func fetchAppGroups(for team: ALTTeam) async throws -> [ALTAppGroup] {
        try await self.fetchAppGroups(team: team)
    }

    @discardableResult
    public func addAppGroup(name: String, groupIdentifier: String, team: ALTTeam? = nil) async throws -> ALTAppGroup {
        let auth = try await self.getSession()
        return try await ALTAppleAPI.shared.addAppGroup(name: name, groupIdentifier: groupIdentifier, team: team ?? auth.team, session: auth.session)
    }

    @discardableResult
    public func updateAppGroup(_ group: ALTAppGroup, team: ALTTeam? = nil) async throws -> ALTAppGroup {
        let auth = try await self.getSession()
        return try await ALTAppleAPI.shared.updateAppGroup(group, team: team ?? auth.team, session: auth.session)
    }

    @discardableResult
    public func assignAppID(_ appID: ALTAppID, to groups: [ALTAppGroup], team: ALTTeam? = nil) async throws -> ALTAppID {
        let auth = try await self.getSession()
        return try await ALTAppleAPI.shared.assign(appID, to: groups, team: team ?? auth.team, session: auth.session)
    }

    @discardableResult
    public func assign(_ appID: ALTAppID, to groups: [ALTAppGroup], team: ALTTeam? = nil) async throws -> ALTAppID {
        try await self.assignAppID(appID, to: groups, team: team)
    }

    @discardableResult
    public func deleteAppGroup(_ group: ALTAppGroup, team: ALTTeam? = nil) async throws -> Bool {
        let auth = try await self.getSession()
        return try await ALTAppleAPI.shared.deleteAppGroup(group, team: team ?? auth.team, session: auth.session)
    }

    public func fetchProvisioningProfiles(team: ALTTeam? = nil) async throws -> [ALTProvisioningProfile] {
        let auth = try await self.getSession()
        return try await ALTAppleAPI.shared.fetchProvisioningProfiles(for: team ?? auth.team, session: auth.session)
    }

    public func fetchProvisioningProfiles(for team: ALTTeam) async throws -> [ALTProvisioningProfile] {
        try await self.fetchProvisioningProfiles(team: team)
    }

    public func downloadProvisioningProfile(for appID: ALTAppID, deviceType: ALTDeviceType = .iphone, team: ALTTeam? = nil) async throws -> ALTProvisioningProfile {
        let auth = try await self.getSession()
        return try await ALTAppleAPI.shared.downloadProvisioningProfile(for: appID, deviceType: deviceType, team: team ?? auth.team, session: auth.session)
    }

    public func fetchProvisioningProfile(for appID: ALTAppID, deviceType: ALTDeviceType = .iphone, team: ALTTeam? = nil) async throws -> ALTProvisioningProfile {
        try await self.downloadProvisioningProfile(for: appID, deviceType: deviceType, team: team)
    }

    @discardableResult
    public func deleteProvisioningProfile(_ profile: ALTProvisioningProfile, team: ALTTeam? = nil) async throws -> Bool {
        let auth = try await self.getSession()
        return try await ALTAppleAPI.shared.deleteProvisioningProfile(profile, team: team ?? auth.team, session: auth.session)
    }
}

class DeveloperPortalProxyWithAuth: DeveloperPortalProxy {
    fileprivate override init() {
        super.init()
    }

    func fetchAccount(session: ALTAppleAPISession) async throws -> ALTAccount {
        try await ALTAppleAPI.shared.fetchAccount(session: session)
    }

    func signIn(appleID: String, 
                password: String, 
                anisetteData: ALTAnisetteData, 
                xcodeVersion: String, 
                machinePassword: String? = nil,
                accountRepairHandler: DeveloperPortal.AccountRepairHandler = DeveloperPortal.defaultAccountRepairHandler,
                verificationHandler: DeveloperPortal.VerificationHandler?) async throws -> (ALTAccount, ALTAppleAPISession) 
    {
        let authSession = try await ALTAppleAPI.shared.authenticate(
            appleID: appleID,
            password: password,
            anisetteData: anisetteData,
            xcodeVersion: xcodeVersion,
            machinePassword: machinePassword,
            accountRepairHandler: accountRepairHandler,
            verificationHandler: verificationHandler
        )
        return (authSession.account, authSession.session)
    }
    
    func authenticateWithToken(adsid: String, xcodeToken: String, anisetteData: ALTAnisetteData, xcodeVersion: String) async throws -> (ALTAccount, ALTAppleAPISession) {
        let session = ALTAppleAPISession(dsid: adsid, authToken: xcodeToken, anisetteData: anisetteData, xcodeVersion: xcodeVersion)
        let account = try await fetchAccount(session: session)
        return (account, session)
    }
}
