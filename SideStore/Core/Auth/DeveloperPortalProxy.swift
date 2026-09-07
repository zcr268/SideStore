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
    
    public func fetchTeams(for account: ALTAccount, session: ALTAppleAPISession) async throws -> [ALTTeam] {
        try await ALTAppleAPI.shared.fetchTeams(for: account, session: session)
    }
    
    public func fetchCertificates(team: ALTTeam, session: ALTAppleAPISession) async throws -> [ALTX509Certificate] {
        try await ALTAppleAPI.shared.fetchCertificates(for: team, session: session)
    }

    public func fetchCertificates(for team: ALTTeam, session: ALTAppleAPISession) async throws -> [ALTX509Certificate] {
        try await self.fetchCertificates(team: team, session: session)
    }
    
    @discardableResult
    public func createCertificate(machineName: String, team: ALTTeam, session: ALTAppleAPISession) async throws -> ALTCertificate {
        try await ALTAppleAPI.shared.addCertificate(machineName: machineName, to: team, session: session)
    }
    
    @discardableResult
    public func revokeCertificate(_ certificate: ALTX509Certificate, team: ALTTeam, session: ALTAppleAPISession) async throws -> Bool {
        try await ALTAppleAPI.shared.revokeCertificate(certificate, for: team, session: session)
    }
    
    public func fetchDevices(for team: ALTTeam, types: ALTDeviceType, session: ALTAppleAPISession) async throws -> [ALTDevice] {
        try await ALTAppleAPI.shared.fetchDevices(for: team, types: types, session: session)
    }
    
    @discardableResult
    public func registerDevice(name: String, identifier: String, type: ALTDeviceType, team: ALTTeam, session: ALTAppleAPISession) async throws -> ALTDevice {
        try await ALTAppleAPI.shared.registerDevice(name: name, identifier: identifier, type: type, team: team, session: session)
    }

    @discardableResult
    public func updateDevice(_ device: ALTDevice, team: ALTTeam, session: ALTAppleAPISession) async throws -> ALTDevice {
        try await ALTAppleAPI.shared.updateDevice(device, team: team, session: session)
    }

    @discardableResult
    public func disableDevice(_ device: ALTDevice, team: ALTTeam, session: ALTAppleAPISession) async throws -> ALTDevice {
        try await ALTAppleAPI.shared.disableDevice(device, team: team, session: session)
    }

    @discardableResult
    public func deleteDevice(_ device: ALTDevice, team: ALTTeam, session: ALTAppleAPISession) async throws -> Bool {
        try await ALTAppleAPI.shared.deleteDevice(device, team: team, session: session)
    }

    public func fetchAppIDs(team: ALTTeam, session: ALTAppleAPISession) async throws -> [ALTAppID] {
        try await ALTAppleAPI.shared.fetchAppIDs(for: team, session: session)
    }

    public func fetchAppIDs(for team: ALTTeam, session: ALTAppleAPISession) async throws -> [ALTAppID] {
        try await self.fetchAppIDs(team: team, session: session)
    }

    @discardableResult
    public func addAppID(name: String, bundleIdentifier: String, team: ALTTeam, session: ALTAppleAPISession) async throws -> ALTAppID {
        try await ALTAppleAPI.shared.addAppID(withName: name, bundleIdentifier: bundleIdentifier, team: team, session: session)
    }

    @discardableResult
    public func updateAppID(_ appID: ALTAppID, team: ALTTeam, session: ALTAppleAPISession) async throws -> ALTAppID {
        try await ALTAppleAPI.shared.updateAppID(appID, team: team, session: session)
    }

    @discardableResult
    public func deleteAppID(_ appID: ALTAppID, team: ALTTeam, session: ALTAppleAPISession) async throws -> Bool {
        try await ALTAppleAPI.shared.deleteAppID(appID, for: team, session: session)
    }

    @discardableResult
    public func deleteAppID(_ appID: ALTAppID, for team: ALTTeam, session: ALTAppleAPISession) async throws -> Bool {
        try await self.deleteAppID(appID, team: team, session: session)
    }

    public func fetchAppGroups(team: ALTTeam, session: ALTAppleAPISession) async throws -> [ALTAppGroup] {
        try await ALTAppleAPI.shared.fetchAppGroups(for: team, session: session)
    }

    public func fetchAppGroups(for team: ALTTeam, session: ALTAppleAPISession) async throws -> [ALTAppGroup] {
        try await self.fetchAppGroups(team: team, session: session)
    }

    @discardableResult
    public func addAppGroup(name: String, groupIdentifier: String, team: ALTTeam, session: ALTAppleAPISession) async throws -> ALTAppGroup {
        try await ALTAppleAPI.shared.addAppGroup(name: name, groupIdentifier: groupIdentifier, team: team, session: session)
    }

    @discardableResult
    public func updateAppGroup(_ group: ALTAppGroup, team: ALTTeam, session: ALTAppleAPISession) async throws -> ALTAppGroup {
        try await ALTAppleAPI.shared.updateAppGroup(group, team: team, session: session)
    }

    @discardableResult
    public func assignAppID(_ appID: ALTAppID, to groups: [ALTAppGroup], team: ALTTeam, session: ALTAppleAPISession) async throws -> ALTAppID {
        try await ALTAppleAPI.shared.assign(appID, to: groups, team: team, session: session)
    }

    @discardableResult
    public func assign(_ appID: ALTAppID, to groups: [ALTAppGroup], team: ALTTeam, session: ALTAppleAPISession) async throws -> ALTAppID {
        try await self.assignAppID(appID, to: groups, team: team, session: session)
    }

    @discardableResult
    public func deleteAppGroup(_ group: ALTAppGroup, team: ALTTeam, session: ALTAppleAPISession) async throws -> Bool {
        try await ALTAppleAPI.shared.deleteAppGroup(group, team: team, session: session)
    }

    public func fetchProvisioningProfiles(team: ALTTeam, session: ALTAppleAPISession) async throws -> [ALTProvisioningProfile] {
        try await ALTAppleAPI.shared.fetchProvisioningProfiles(for: team, session: session)
    }

    public func fetchProvisioningProfiles(for team: ALTTeam, session: ALTAppleAPISession) async throws -> [ALTProvisioningProfile] {
        try await self.fetchProvisioningProfiles(team: team, session: session)
    }

    public func downloadProvisioningProfile(for appID: ALTAppID, deviceType: ALTDeviceType = .iphone, team: ALTTeam, session: ALTAppleAPISession) async throws -> ALTProvisioningProfile {
        try await ALTAppleAPI.shared.downloadProvisioningProfile(for: appID, deviceType: deviceType, team: team, session: session)
    }

    public func fetchProvisioningProfile(for appID: ALTAppID, deviceType: ALTDeviceType = .iphone, team: ALTTeam, session: ALTAppleAPISession) async throws -> ALTProvisioningProfile {
        try await self.downloadProvisioningProfile(for: appID, deviceType: deviceType, team: team, session: session)
    }

    @discardableResult
    public func deleteProvisioningProfile(_ profile: ALTProvisioningProfile, team: ALTTeam, session: ALTAppleAPISession) async throws -> Bool {
        try await ALTAppleAPI.shared.deleteProvisioningProfile(profile, team: team, session: session)
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
