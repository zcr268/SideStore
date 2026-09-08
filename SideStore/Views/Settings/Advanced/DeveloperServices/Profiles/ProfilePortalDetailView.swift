//
//  ProfilePortalDetailView.swift
//  SideStore
//
//  Created by Magesh K on 2/9/26.
//  Copyright © 2026 SideStore. All rights reserved.
//

import SwiftUI
import SideSign

struct ProfilePortalDetailView: View {
    let profile: ALTListedProvisioningProfile
    @ObservedObject var viewModel: DeveloperServicesViewModel
    weak var presentingViewController: UIViewController?
    @Environment(\.presentationMode) var presentationMode

    @State private var showDeleteAlert = false

    var body: some View {
        List {
            Section(header: Text("Profile Metadata")) {
                InfoRow(label: "Name", value: profile.name)
                InfoRow(label: "UUID", value: profile.uuid.uuidString)
                if let identifier = profile.identifier {
                    InfoRow(label: "Identifier", value: identifier)
                }
                if let status = profile.status {
                    InfoRow(label: "Status", value: status)
                }
                if let type = profile.type {
                    InfoRow(label: "Type", value: type)
                }
                if let bundleID = profile.bundleIdentifier {
                    InfoRow(label: "App Bundle ID", value: bundleID)
                }
                if let teamName = viewModel.team?.name {
                    InfoRow(label: "Team Name", value: teamName)
                }
                if let teamID = viewModel.team?.identifier {
                    InfoRow(label: "Team Identifier", value: teamID)
                }
                InfoRow(label: "Expiration Date", value: formatDate(profile.dateExpire), valueColor: profile.dateExpire < Date() ? .red : .primary)
                if let isTeam = profile.isTeamProfile {
                    InfoRow(label: "Managed By", value: isTeam ? "Xcode (Team Profile)" : "Manual (Portal)")
                }
                if let isFree = profile.isFreeProvisioningProfile {
                    InfoRow(label: "Free Developer Profile", value: isFree ? "Yes" : "No")
                }
            }

            if let devices = profile.deviceIds, !devices.isEmpty {
                Section(header: Text("Provisioned Devices (\(devices.count))")) {
                    ForEach(devices, id: \.self) { deviceID in
                        Text(deviceID)
                            .font(.system(.caption, design: .monospaced))
                    }
                }
            }

            Section {
                SwiftUI.Button {
                    Task {
                        guard let downloaded = await viewModel.downloadProfile(profile: profile) else { return }
                        let safeName = profile.name.replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: ":", with: "_")
                        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(safeName).mobileprovision")
                        do {
                            try downloaded.data.write(to: tempURL)
                            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
                            if let popover = activityVC.popoverPresentationController {
                                popover.sourceView = presentingViewController?.view
                            }
                            presentingViewController?.present(activityVC, animated: true)
                        } catch {
                            debugLog("[ProfilePortalDetailView] Failed to write profile to temp: \(error)")
                        }
                    }
                } label: {
                    HStack {
                        Spacer()
                        if viewModel.isActionLoading {
                            ProgressView()
                        } else {
                            Image(systemName: "arrow.down.doc")
                            Text("Download Profile (.mobileprovision)")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                }
                .disabled(viewModel.isActionLoading)
            }

            Section {
                SwiftUI.Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: "trash")
                        Text("Delete Profile from Portal")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
            }
        }
        #if !os(tvOS)
        .listStyle(InsetGroupedListStyle())
        #else
        .listStyle(GroupedListStyle())
        #endif
        .navigationTitle(profile.name)
        .refreshable {
            await viewModel.fetchProfiles(presentingViewController: presentingViewController, isPullToRefresh: true)
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Delete Provisioning Profile?"),
                message: Text("Are you sure you want to delete '\(profile.name)' from the Apple Developer Portal?"),
                primaryButton: .destructive(Text("Delete")) {
                    Task {
                        let success = await viewModel.deleteProfile(profile, presentingViewController: presentingViewController)
                        if success {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .developerServicesToast(viewModel: viewModel)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
