//
//  ALTAppPermission.swift
//  SideStore
//
//  Created by Joseph Mattiello on 2/28/23.
//  Copyright © 2923 Joseph Mattiello. All rights reserved.
//

import Foundation

@objc
public enum ALTAppPermissionType: Int, CaseIterable {
    case photos
    case camera
    case location
    case contacts
    case reminders
    case appleMusic = 6
    case microphone
    case speechRecognition
    case backgroundAudio
    case backgroundFetch
    case bluetooth
    case network
    case calendars
    case touchID
    case faceID
    case siri
    case motion

    public var stringValue: String {
        switch self {
        case .photos:
            return "photos"
        case .camera:
            return "camera"
        case .location:
            return "location"
        case .contacts:
            return "contacts"
        case .reminders:
            return "reminders"
        case .appleMusic:
            return "music"
        case .microphone:
            return "microphone"
        case .speechRecognition:
            return "speech-recognition"
        case .backgroundAudio:
            return "background-audio"
        case .backgroundFetch:
            return "background-fetch"
        case .bluetooth:
            return "bluetooth"
        case .network:
            return "network"
        case .calendars:
            return "calendars"
        case .touchID:
            return "touchid"
        case .faceID:
            return "faceid"
        case .siri:
            return "siri"
        case .motion:
            return "motion"
        }
    }
}
