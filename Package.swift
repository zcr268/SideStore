// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import os.log
import PackageDescription

let env: [String: Bool] = [
    "USE_CARGO": false,
    "USE_CXX_INTEROP": false,
    "USE_CXX_MODULES": false,
    "INHIBIT_UPSTREAM_WARNINGS": true,
    "STATIC_LIBRARY": false,
]

let USE_CARGO = envBool("USE_CARGO")
let USE_CXX_INTEROP = envBool("USE_CXX_INTEROP")
let USE_CXX_MODULES = envBool("USE_CXX_MODULES")
let INHIBIT_UPSTREAM_WARNINGS = envBool("INHIBIT_UPSTREAM_WARNINGS")
let STATIC_LIBRARY = envBool("STATIC_LIBRARY")

let unsafe_flags: [String] = INHIBIT_UPSTREAM_WARNINGS ? ["-w"] : []
let unsafe_flags_cxx: [String] = INHIBIT_UPSTREAM_WARNINGS ? ["-w", "-Wno-module-import-in-extern-c"] : ["-Wno-module-import-in-extern-c"]

let dependencies: [Package.Dependency] = [
    .package(url: "https://github.com/JoeMatt/Roxas", from: "1.2.2"),
    .package(url: "https://github.com/johnxnguyen/Down", branch: "master"),
    .package(url: "https://github.com/kean/Nuke", from: "7.0.0"),
    .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.0"),
    .package(url: "https://github.com/microsoft/appcenter-sdk-apple", from: "4.2.0"),
    .package(url: "https://github.com/SideStore/AltSign", from: "1.0.2"),
	.package(url: "https://github.com/SideStore/iMobileDevice.swift", from: "1.0.5"),
//	.package(path: "../iMobileDevice.swift"),
    .package(url: "https://github.com/SideStore/SideKit", from: "0.1.0"),
    .package(url: "https://github.com/SwiftPackageIndex/SemanticVersion", from: "0.3.5"),
	.package(url: "https://github.com/krzyzanowskim/OpenSSL.git", .upToNextMinor(from: "1.1.1700")),
	.package(url: "https://github.com/JoeMatt/SwiftPMPlugins.git", .upToNextMinor(from: "1.0.0"))
] // + dependencies_cargo

let package = Package(
    name: "SideStore",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14),
        .tvOS(.v14),
        .macCatalyst(.v14),
        .macOS(.v11),
    ],

    products: [
        .executable(
            name: "SideStore",
            targets: ["SideStore"]
        ),

        .executable(
            name: "SideWidget",
            targets: ["SideWidget"]
        ),

		.library(
			name: "SideStoreAppKit",
			targets: ["SideStoreAppKit"]),

		.plugin(name: "CargoPlugin", targets: ["CargoPlugin"]),
    ],

    dependencies: dependencies,
    targets: [
        // MARK: - SideStore

        .executableTarget(
            name: "SideStore",
            dependencies: [
				"SideStoreAppKit",
                "SidePatcher",
                "EmotionalDamage",
                "MiniMuxerSwift",
                "SideStoreCore",
                "Shared",
                "Nuke",
                "Down",
                "AltSign",
                "SideKit",
				"KeychainAccess",
				"SemanticVersion",
				.product(name: "libimobiledevice", package: "iMobileDevice.swift"),
                .product(name: "Roxas", package: "Roxas"),
				.product(name: "RoxasUI", package: "Roxas"),
                .product(name: "AppCenterAnalytics", package: "appcenter-sdk-apple"),
                .product(name: "AppCenterCrashes", package: "appcenter-sdk-apple"),
            ],
			resources: [
				.process("Resources/XIB"),
				.process("Resources/Storyboards"),
				.process("Resources/Base.lproj"),
				.process("Resources/Assets"),
				.process("Resources/Sounds"),
				.process("Resources/Settings.bundle"),
				.copy("Resources/JSON/apps-alpha.json"),
				.copy("Resources/JSON/apps.json")
			],
            linkerSettings: [
				.linkedFramework("UIKit", .when(platforms: [.iOS, .macCatalyst, .tvOS])),
                .linkedFramework("Avfoundation"),
                .linkedFramework("Combine"),
                .linkedFramework("Network"),
                .linkedFramework("CoreData"),
                .linkedFramework("UniformTypeIdentifiers"),
                .linkedFramework("QuickLook", .when(platforms: [.iOS, .macCatalyst])),
                .linkedFramework("AuthenticationServices", .when(platforms: [.iOS, .macCatalyst])),
                .linkedFramework("SafariServices", .when(platforms: [.iOS, .macCatalyst])),
                .linkedFramework("Intents", .when(platforms: [.iOS, .macCatalyst])),
                .linkedFramework("IntentsUI", .when(platforms: [.iOS, .macCatalyst])),
                .linkedFramework("MessageUI", .when(platforms: [.iOS, .macCatalyst])),
                .linkedFramework("ARKit", .when(platforms: [.iOS, .macCatalyst])),
                .linkedFramework("CoreHaptics", .when(platforms: [.iOS, .macCatalyst])),
                .linkedFramework("AudioToolbox", .when(platforms: [.iOS, .macCatalyst])),
                .linkedFramework("WidgetKit", .when(platforms: [.iOS, .macCatalyst])),
                .linkedFramework("UserNotifications", .when(platforms: [.iOS, .macCatalyst])),
                .linkedFramework("MobileCoreServices", .when(platforms: [.iOS, .macCatalyst])),
				.linkedLibrary("AppleArchive")
            ],
			plugins: [
				.plugin(name: "IntentBuilderPlugin", package: "SwiftPMPlugins"),
				.plugin(name: "LoggerPlugin", package: "SwiftPMPlugins")
			]
        ),

		.target(
			name: "SideStoreAppKit",
			dependencies: [
				"SidePatcher",
				"EmotionalDamage",
				"MiniMuxerSwift",
				"SideStoreCore",
				"Shared",
				"Nuke",
				"Down",
				"AltSign",
				"SideKit",
				.product(name: "Roxas", package: "Roxas"),
				.product(name: "RoxasUI", package: "Roxas"),
				.product(name: "AppCenterAnalytics", package: "appcenter-sdk-apple"),
				.product(name: "AppCenterCrashes", package: "appcenter-sdk-apple"),
			],
			resources: [
			],
			linkerSettings: [
				.linkedFramework("UIKit", .when(platforms: [.iOS, .macCatalyst, .tvOS])),
				.linkedFramework("Avfoundation"),
				.linkedFramework("Combine"),
				.linkedFramework("Network"),
				.linkedFramework("CoreData"),
				.linkedFramework("UniformTypeIdentifiers"),
				.linkedFramework("QuickLook", .when(platforms: [.iOS, .macCatalyst])),
				.linkedFramework("AuthenticationServices", .when(platforms: [.iOS, .macCatalyst])),
				.linkedFramework("SafariServices", .when(platforms: [.iOS, .macCatalyst])),
				.linkedFramework("Intents", .when(platforms: [.iOS, .macCatalyst])),
				.linkedFramework("IntentsUI", .when(platforms: [.iOS, .macCatalyst])),
				.linkedFramework("MessageUI", .when(platforms: [.iOS, .macCatalyst])),
				.linkedFramework("ARKit", .when(platforms: [.iOS, .macCatalyst])),
				.linkedFramework("CoreHaptics", .when(platforms: [.iOS, .macCatalyst])),
				.linkedFramework("AudioToolbox", .when(platforms: [.iOS, .macCatalyst])),
				.linkedFramework("WidgetKit", .when(platforms: [.iOS, .macCatalyst])),
				.linkedFramework("UserNotifications", .when(platforms: [.iOS, .macCatalyst])),
				.linkedFramework("MobileCoreServices", .when(platforms: [.iOS, .macCatalyst])),
				.linkedLibrary("AppleArchive")
			],
			plugins: [
				.plugin(name: "IntentBuilderPlugin", package: "SwiftPMPlugins"),
				.plugin(name: "LoggerPlugin", package: "SwiftPMPlugins")
			]
		),

        // MARK: - SideWidget

        .executableTarget(
            name: "SideWidget",
			plugins: [
				.plugin(name: "IntentBuilderPlugin", package: "SwiftPMPlugins"),
				.plugin(name: "LoggerPlugin", package: "SwiftPMPlugins")
			]
        ),

        // MARK: - EmotionalDamage

        .target(
            name: "EmotionalDamage",
            dependencies: ["em_proxy"]
        ),

        .binaryTarget(
            name: "em_proxy",
            path: "Dependencies/em_proxy/em_proxy.xcframework.zip"
        ),

        .testTarget(
            name: "EmotionalDamageTests",
            dependencies: ["EmotionalDamage"]
        ),

        // MARK: - SidePatcher

        .target(
            name: "SidePatcher",
            dependencies: [
                .product(name: "Roxas", package: "Roxas"),
                .product(name: "RoxasUI", package: "Roxas"),
            ]
        ),

        .testTarget(
            name: "SidePatcherTests",
            dependencies: ["SidePatcher"]
        ),

        // MARK: - MiniMuxer

        .target(
            name: "MiniMuxerSwift",
            dependencies: [
                "minimuxer",
				.product(name: "libimobiledevice", package: "iMobileDevice.swift")
            ],
			plugins: [
				.plugin(name: "LoggerPlugin", package: "SwiftPMPlugins")
			]
        ),

        .binaryTarget(
            name: "minimuxer",
            path: "Dependencies/minimuxer/minimuxer.xcframework.zip"
        ),

        .testTarget(
            name: "MiniMuxerTests",
            dependencies: [
				"MiniMuxerSwift",
				.product(name: "libimobiledevice", package: "iMobileDevice.swift")
			]
        ),

        // MARK: - Shared

        .target(
            name: "Shared",
            dependencies: [
                "SideKit",
                "AltSign",
            ]
        ),

        .testTarget(
            name: "SharedTests",
            dependencies: [
                "Shared",
                "SideKit",
                "AltSign",
            ]
        ),

        // MARK: - SideBackup

        .executableTarget(
            name: "SideBackup",
            dependencies: []
        ),


        // MARK: - SideStoreCore

        .target(
            name: "SideStoreCore",
            dependencies: [
                "Shared",
                "KeychainAccess",
                "AltSign",
                "SemanticVersion",
                .product(name: "Roxas", package: "Roxas"),
            ],
			plugins: [
				.plugin(name: "IntentBuilderPlugin", package: "SwiftPMPlugins"),
				.plugin(name: "LoggerPlugin", package: "SwiftPMPlugins")
			]
        ),

        .testTarget(
            name: "SideStoreCoreTests",
            dependencies: [
                "SideStoreCore",
				"KeychainAccess",
				"AltSign",
				"SemanticVersion",
				"SideKit"
            ]
        ),

		// MARK: - Plugins
		.plugin(name: "CargoPlugin", capability: .buildTool()),
//		.plugin(name: "CargoPlugin-Generate", capability: .command(intent: PluginCommandIntent)),

    ],
    swiftLanguageVersions: [.v5],
    cLanguageStandard: .gnu11,
    cxxLanguageStandard: .gnucxx14
)

// MARK: - Helpers

func envBool(_ key: String) -> Bool {
    guard let value = ProcessInfo.processInfo.environment[key] else { return env[key, default: true] }
    let trueValues = ["1", "on", "true", "yes"]
    return trueValues.contains(value.lowercased())
}


// MARK: - SideDaemon
//        .executable(
//            name: "SideDaemon",
//            targets: ["SideDaemon"]),

//        .executableTarget(
//            name: "SideDaemon",
//            dependencies: [
//				"Shared",
//				.product(name: "SideKit", package: "SideKit"),
//				.product(name: "AltSign", package: "AltSign"),
//				.product(name: "CoreCrypto", package: "AltSign"),
//				.product(name: "CCoreCrypto", package: "AltSign"),
//				.product(name: "LaunchAtLogin", package: "LaunchAtLogin"),
//			]
//        ),
//
//        .testTarget(
//            name: "SideDaemonTests",
//            dependencies: ["SideDaemon"]
//        ),


// let dependencies_cargo: [Package.Dependency] = {
//	USE_CARGO ? [
//		// CargoPlugin
//		.package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.3"),
//		.package(url: "https://github.com/apple/swift-package-manager.git", branch: "release/5.7"),
//		.package(url: "https://github.com/apple/swift-tools-support-core.git", branch: "release/5.7"),
//	] : []
// }()

// let cargo_targets: [Target] = [
//	.executableTarget(
//		name: "Cargo",
//		dependencies: [
//			.product(name: "ArgumentParser", package: "swift-argument-parser"),
//			.product(name: "SwiftPM-auto", package: "swift-package-manager"),
//			.product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core")
//		]
//	),
//
//	.testTarget(
//		name: "CargoTests",
//		dependencies: ["Cargo"],
//		exclude: [
//			"swiftlint",
//			"xcframework"
//		]
//	),
//
//	.plugin(
//		name: "CargoPlugin",
//		capability: .buildTool(),
//		dependencies: [
//			"Cargo"
//		]
//	),
//
//	.plugin(
//		name: "CargoPlugin-Generate",
//		capability: .command(
//			intent: .custom(
//				verb: "generate-code-from-rust",
//				description: "Creates .c code from your `rust` code"
//			),
//			permissions: [
//				.writeToPackageDirectory(reason: "This command generates source code")
//			]
//		),
//		dependencies: ["Cargo"]
//	)
// ]
