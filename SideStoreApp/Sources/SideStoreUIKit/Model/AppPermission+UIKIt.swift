//
//  AppPermission+UIKit.swift
//  AltStore
//
//  Created by Riley Testut on 7/23/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

import CoreData
import SideStoreCore
import UIKit

// ALTAppPermissionType UIKit Extensions
public extension ALTAppPermissionType {
    var icon: UIImage? {
        switch self {
        case .photos: return UIImage(systemName: "photo.on.rectangle.angled")
        case .camera: return UIImage(systemName: "camera.fill")
        case .location: return UIImage(systemName: "location.fill")
        case .contacts: return UIImage(systemName: "person.2.fill")
        case .reminders: return UIImage(systemName: "checklist")
        case .appleMusic: return UIImage(systemName: "music.note")
        case .microphone: return UIImage(systemName: "mic.fill")
        case .speechRecognition: return UIImage(systemName: "waveform.and.mic")
        case .backgroundAudio: return UIImage(systemName: "speaker.fill")
        case .backgroundFetch: return UIImage(systemName: "square.and.arrow.down")
        case .bluetooth: return UIImage(systemName: "wave.3.right")
        case .network: return UIImage(systemName: "network")
        case .calendars: return UIImage(systemName: "calendar")
        case .touchID: return UIImage(systemName: "touchid")
        case .faceID: return UIImage(systemName: "faceid")
        case .siri: return UIImage(systemName: "mic.and.signal.meter.fill")
        case .motion: return UIImage(systemName: "figure.walk.motion")
        default:
            return nil
        }
    }
}
