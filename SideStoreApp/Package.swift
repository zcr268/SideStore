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

let unsafe_flags: [String] = INHIBIT_UPSTREAM_WARNINGS ?
	["-w"] :
	[]
let unsafe_flags_cxx: [String] = INHIBIT_UPSTREAM_WARNINGS ?
	["-w", "-Wno-module-import-in-extern-c"] :
	["-Wno-module-import-in-extern-c"]

let dependencies: [Package.Dependency] = [

	// Side Store
	.package(url: "https://github.com/SideStore/AltSign", from: "1.0.3"),
	.package(url: "https://github.com/SideStore/iMobileDevice.swift", from: "1.0.5"),
	.package(url: "https://github.com/SideStore/SideKit", from: "0.1.0"),

	// JoeMatt
	.package(url: "https://github.com/JoeMatt/Roxas", from: "1.2.2"),

	// 3rd Party
    .package(url: "https://github.com/johnxnguyen/Down", branch: "master"),
    .package(url: "https://github.com/kean/Nuke", from: "7.0.0"),
    .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.0"),
    .package(url: "https://github.com/microsoft/appcenter-sdk-apple", from: "4.2.0"),
    .package(url: "https://github.com/SwiftPackageIndex/SemanticVersion", from: "0.3.5"),

	// Plugins
		// IntentBuilder for spm support of intents and Logger injection
	.package(url: "https://github.com/JoeMatt/SwiftPMPlugins.git", .upToNextMinor(from: "1.0.0")),
		// Generate swift files with git head info
	.package(url: "https://github.com/elegantchaos/Versionator.git", from: "1.0.3"),
		// plists from .json, including Info.plist
	.package(url: "https://github.com/elegantchaos/InfomaticPlugin.git", branch: "main"),
		// Swiftlint
	.package(url: "https://github.com/lukepistrol/SwiftLintPlugin", from: "0.2.2"),
		// git secrets from env (for adding sensative api keys via CI/CD,
		// `swift package plugin --allow-writing-to-package-directory secret-keys generate`
		// or `mint run secret-keys generate`
	.package(url: "https://github.com/simorgh3196/swift-secret-keys", from: "0.0.1"),
		// Swift docc generator
		// `swift package generate-documentation` to call
		// or inline creation
		// `swift package --allow-writing-to-directory ./docs \
		//	generate-documentation --target MyFramework --output-path ./docs`
		// to preview:
		// `swift package --disable-sandbox preview-documentation --target MyFramework
		// Hosting https://apple.github.io/swift-docc-plugin/documentation/swiftdoccplugin/
	.package(url: "https://github.com/apple/swift-docc-plugin", from: "1.1.0"),

		// Generate compile time checked URLs
		// This will compile
		// let validUrl = URL(safeString: "https://example.tld")
		// This won't
		// let invalidUrl = URL(safeString: "https://example./tld")
//	.package(url: "https://github.com/JoeMatt/SwiftSafeURL", branch: "main"),//from: "0.4.2"),

		// Secrets manager using `.env`
	.package(url: "https://github.com/vdka/SecretsManager.git", from: "1.0.0"),

		// Generate `PackageBuild` struct with build time info about repo
	.package(url: "https://github.com/DimaRU/PackageBuildInfo", branch: "master"),

	/*
		//  Plugin for simply updating your Package.swift file consistently and understandably.
	 .package(url: "https://github.com/mackoj/PackageGeneratorPlugin.git", from: "0.3.0"),
		// Plugin for quickly updating your Schemes files
	 .package(url: "https://github.com/mackoj/SchemeGeneratorPlugin.git", from: "0.5.5"),
	 .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "0.45.0"),

	 */

	// Old style plugins
		// `Danger` https://danger.systems/swift/ for CI/CD
		// Additinal plugins https://github.com/danger/awesome-danger
//	.package(url: "https://github.com/danger/swift.git", from: "3.0.0"), // dev
//	.package(url: "https://github.com/f-meloni/danger-swift-coverage", from: "0.1.0") // dev
	.package(url: "https://github.com/IgorMuzyka/ignore", from: "0.0.2"),
] // + dependencies_cargo

let package = Package(
    name: "SideStore",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14),
        .tvOS(.v14),
        .macCatalyst(.v14),
        .macOS(.v12),
    ],

    products: [
		// SideWidget Executable
        .executable(
            name: "SideStore",
            targets: ["SideStore"]
        ),

		// SideStoreAppKit
		.library(
			name: "SideStoreAppKit",
			targets: ["SideStoreAppKit"]),

		.library(
			name: "SideStoreAppKit-Static",
			type: .static,
			targets: ["SideStoreAppKit"]),

		.library(
			name: "SideStoreAppKit-Dynamic",
			type: .dynamic,
			targets: ["SideStoreAppKit"]),

		// SideStoreCore
		.library(
			name: "SideStoreCore",
			targets: ["SideStoreCore"]),

		.library(
			name: "SideStoreCore-Static",
			type: .static,
			targets: ["SideStoreCore"]),

		.library(
			name: "SideStoreCore-Dynamic",
			type: .dynamic,
			targets: ["SideStoreCore"]),

		// WidgetKit
		.library(
			name: "SideWidget",
			targets: ["SideWidget"]),

		.library(
			name: "SideWidget-Static",
			type: .static,
			targets: ["SideWidget"]),

		.library(
			name: "SideWidget-Dynamic",
			type: .dynamic,
			targets: ["SideWidget"]),

		// Plugins
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
			exclude: [
				"Resources/Info.plist",
				"Resources/AltBackup.ipa",
				"Resources/Info.info",
				"Resources/Info.plist",
				"Resources/tempEnt.plist",
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
                .linkedFramework("MobileCoreServiceGits", .when(platforms: [.iOS, .macCatalyst])),
				.linkedLibrary("AppleArchive")
            ],
			plugins: [
				.plugin(name: "IntentBuilderPlugin", package: "SwiftPMPlugins"),
				.plugin(name: "LoggerPlugin", package: "SwiftPMPlugins"),
				.plugin(name: "InfomaticPlugin", package: "InfomaticPlugin"),
				.plugin(name: "PackageBuildInfoPlugin", package: "PackageBuildInfo"),
				.plugin(name: "SecretsManagerPlugin", package: "SecretsManager"),
//				.plugin(name: "SafeURLPlugin", package: "SafeURLPlugin"),
//				.plugin(name: "VersionatorPlugin", package: "Versionator"),
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
				"KeychainAccess",
				.product(name: "libimobiledevice", package: "iMobileDevice.swift"),
				.product(name: "CCoreCrypto", package: "AltSign"),
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
				.plugin(name: "LoggerPlugin", package: "SwiftPMPlugins"),
//				.plugin(name: "SafeURLPlugin", package: "SafeURLPlugin"),
			]
		),

        // MARK: - SideWidget

		.target(
			name: "SideWidget",
			dependencies: [
				"Shared",
				"SideStoreCore",
				"AltSign",
				"SideKit",
				"SemanticVersion",
				"KeychainAccess",
				.product(name: "RoxasUI", package: "Roxas"),
				.product(name: "CCoreCrypto", package: "AltSign"),
			],
			exclude: [
				"Resources/Info.plist",
				"Resources/SideWidgetExtension.entitlements",
			],
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

		// For local, run `make zip`
//        .binaryTarget(
//            name: "em_proxy",
//            path: "Dependencies/em_proxy/em_proxy.xcframework.zip"
//        ),

		.binaryTarget(
			name: "em_proxy",
			url: "https://github.com/SideStore/em_proxy/releases/download/build/em_proxy.xcframework.zip",
			checksum: "8c745d9fdf121ab33b1007394c283d1a1a74a30efa0a52b22c29b766ea7d6a8e"
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
			]
        ),

		// For local, run `make zip`
//        .binaryTarget(
//            name: "minimuxer",
//            path: "Dependencies/minimuxer/minimuxer.xcframework.zip"
//        ),

		.binaryTarget(
			name: "minimuxer",
			url: "https://github.com/SideStore/minimuxer/releases/download/build/minimuxer.xcframework.zip",
			checksum: "7a5423ad301dacc664ee5141942781f69753346bae148699ea21b1debdc0d3b5"
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
				.product(name: "CCoreCrypto", package: "AltSign"),
            ],
			plugins: [
				.plugin(name: "LoggerPlugin", package: "SwiftPMPlugins"),
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
            dependencies: [],
			plugins: [
				.plugin(name: "LoggerPlugin", package: "SwiftPMPlugins"),
			]
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
				.plugin(name: "LoggerPlugin", package: "SwiftPMPlugins"),
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

		.target(name: "PackageConfigs", dependencies: [
			"IgnoreConfig",
		])
		// MARK: Danger.swift
//		.target(
//			name: "DangerDependencies",
//			dependencies: [
//				.product(name: "Danger", package: "swift"),
//				.product(name: "DangerSwiftCoverage", package: "danger-swift-coverage"),
//			]), // dev

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

#if canImport(IgnoreConfig)
// https://github.com/IgorMuzyka/ignore
// Ignore warnings in Packages
import IgnoreConfig

// add the list of targets you wish to preserve the warnings for as excluded
IgnoreConfig(excludedTargets: ["YourMainTarget", "SomeOtherTargetOfYours"]).write()
#endif

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
