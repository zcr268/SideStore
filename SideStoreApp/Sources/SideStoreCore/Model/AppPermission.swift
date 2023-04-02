//
//  AppPermission.swift
//  AltStore
//
//  Created by Riley Testut on 7/23/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

import CoreData

public extension ALTAppPermissionType {
    var localizedShortName: String? {
        switch self {
        case .photos: return NSLocalizedString("Photos", comment: "")
        case .backgroundAudio: return NSLocalizedString("Audio (BG)", comment: "")
        case .backgroundFetch: return NSLocalizedString("Fetch (BG)", comment: "")
        default: return nil
        }
    }

    var localizedName: String? {
        switch self {
        case .photos: return NSLocalizedString("Photos", comment: "")
        case .camera: return NSLocalizedString("Camera", comment: "")
        case .location: return NSLocalizedString("Location", comment: "")
        case .contacts: return NSLocalizedString("Contacts", comment: "")
        case .reminders: return NSLocalizedString("Reminders", comment: "")
        case .appleMusic: return NSLocalizedString("Apple Music", comment: "")
        case .microphone: return NSLocalizedString("Microphone", comment: "")
        case .speechRecognition: return NSLocalizedString("Speech Recognition", comment: "")
        case .backgroundAudio: return NSLocalizedString("Background Audio", comment: "")
        case .backgroundFetch: return NSLocalizedString("Background Fetch", comment: "")
        case .bluetooth: return NSLocalizedString("Bluetooth", comment: "")
        case .network: return NSLocalizedString("Network", comment: "")
        case .calendars: return NSLocalizedString("Calendars", comment: "")
        case .touchID: return NSLocalizedString("Touch ID", comment: "")
        case .faceID: return NSLocalizedString("Face ID", comment: "")
        case .siri: return NSLocalizedString("Siri", comment: "")
        case .motion: return NSLocalizedString("Motion", comment: "")
        default: return nil
        }
    }
}

@objc(AppPermission)
public class AppPermission: NSManagedObject, Decodable, Fetchable, NSKeyValueObservingCustomization {
	public static func keyPathsAffectingValue(for key: AnyKeyPath) -> Set<AnyKeyPath> {
		print("keyPathsAffectingValue: \(String(describing: key))")
		return Set<AnyKeyPath>([key])
	}

	public static func automaticallyNotifiesObservers(for key: AnyKeyPath) -> Bool {
		print("automaticallyNotifiesObservers: \(String(describing: key))")
		return true
	}

    /* Properties */
	@objc(type)
    @NSManaged public var _type: String
	@nonobjc
	public var type: ALTAppPermissionType {
		get {
			ALTAppPermissionType(rawValue: _type)
		}
		set {
			_type = newValue.stringValue
		}
	}

    @NSManaged public var usageDescription: String

    /* Relationships */
    @NSManaged public private(set) var app: StoreApp!

    override private init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case usageDescription
    }

    public required init(from decoder: Decoder) throws {
        guard let context = decoder.managedObjectContext else { preconditionFailure("Decoder must have non-nil NSManagedObjectContext.") }

        super.init(entity: AppPermission.entity(), insertInto: context)

        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            usageDescription = try container.decode(String.self, forKey: .usageDescription)

            let rawType = try container.decode(String.self, forKey: .type)
//			guard
				let type = ALTAppPermissionType(rawValue: rawType)
//			else {
//				throw DecodingError.dataCorrupted(
//					DecodingError.Context(codingPath: [CodingKeys.type],
//										  debugDescription: "Invalid value for `ALTAppPermissionType` \"\(rawType)\""))
//			}
			self.type = type
        } catch {
            if let context = managedObjectContext {
                context.delete(self)
            }

            throw error
        }
    }
}

public extension AppPermission {
    @nonobjc class func fetchRequest() -> NSFetchRequest<AppPermission> {
        NSFetchRequest<AppPermission>(entityName: "AppPermission")
    }
}
