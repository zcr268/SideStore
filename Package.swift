// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import os.log
import PackageDescription

let env: [String: Bool] = [
    "USE_CARGO": false,
    "USE_CXX_INTEROP": false,
    "USE_CXX_MODULES": false,
    "INHIBIT_UPSTREAM_WARNINGS": false,
    "STATIC_LIBRARY": false,
]

let USE_CARGO = envBool("USE_CARGO")
let USE_CXX_INTEROP = envBool("USE_CXX_INTEROP")
let USE_CXX_MODULES = envBool("USE_CXX_MODULES")
let INHIBIT_UPSTREAM_WARNINGS = envBool("INHIBIT_UPSTREAM_WARNINGS")
let STATIC_LIBRARY = envBool("STATIC_LIBRARY")

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

let dependencies: [Package.Dependency] = [
	.package(url: "https://github.com/JoeMatt/Roxas", from: "1.2.2"),
	.package(url: "https://github.com/johnxnguyen/Down", branch: "master"),
	.package(url: "https://github.com/kean/Nuke", from: "7.0.0"),
	.package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.0"),
//	.package(url: "https://github.com/krzyzanowskim/OpenSSL", from: "1.1.180"),
	.package(url: "https://github.com/microsoft/appcenter-sdk-apple", from: "4.2.0"),
	.package(url: "https://github.com/SideStore/AltSign", branch: "master"),
	.package(url: "https://github.com/SideStore/SideKit", branch: "main"),
	.package(url: "https://github.com/sindresorhus/LaunchAtLogin", from: "4.1.0"),
	.package(url: "https://github.com/SwiftPackageIndex/SemanticVersion", from: "0.3.5"),
] // + dependencies_cargo

let package = Package(
    name: "SideStoreCore",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v12),
//        .tvOS(.v12),
//        .macOS(.v12),
    ],

    products: [
		.executable(
			name: "SideStore",
			targets: ["SideStore"]),

		.executable(
			name: "SideWidget",
			targets: ["SideWidget"]),

        .executable(
            name: "SideDaemon",
            targets: ["SideDaemon"]),

        .library(name: "EmotionalDamage", targets: ["EmotionalDamage"]),
        .library(name: "MiniMuxerSwift", targets: ["MiniMuxerSwift"]),
		.library(name: "SideStoreCore", targets: ["SideStoreCore"]),
    ],

    dependencies: dependencies,
    targets: [

		// MARK: - SideStore
		.executableTarget(
			name: "SideStore",
			dependencies: [
				"AltPatcher",
				"EmotionalDamage",
				"MiniMuxerSwift",
				"SideStoreCore",
				"Shared",
				.product(name: "Down", package: "Down"),
				.product(name: "AltSign", package: "AltSign"),
				.product(name: "Nuke", package: "Nuke"),
				.product(name: "Roxas", package: "Roxas"),
				.product(name: "RoxasUI", package: "Roxas"),
				.product(name: "AppCenterAnalytics", package: "appcenter-sdk-apple"),
				.product(name: "AppCenterCrashes", package: "appcenter-sdk-apple")
			],
			linkerSettings: [
				.linkedFramework("UIKit"),
				.linkedFramework("Avfoundation"),
				.linkedFramework("Combine"),
				.linkedFramework("AppleArchive"),
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
			]
		),

		// MARK: - SideWidget
		.executableTarget(
			name: "SideWidget"
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

		// MARK: - AltPatcher

		.target(
			name: "AltPatcher",
			dependencies: []
		),

		.testTarget(
			name: "AltPatcherTests",
			dependencies: ["AltPatcher"]
		),

        // MARK: - MiniMuxer

        .target(
            name: "MiniMuxerSwift",
            dependencies: ["minimuxer"],
            cSettings: [
//                .headerSearchPath("Dependencies/minimuxer/include"),
            ],
            cxxSettings: [
            ],
            swiftSettings: [
            ],
            linkerSettings: [
            ]
        ),

        .binaryTarget(
            name: "minimuxer",
            path: "Dependencies/minimuxer/minimuxer.xcframework.zip"
        ),

        .testTarget(
            name: "MiniMuxerTests",
            dependencies: ["MiniMuxerSwift"]
        ),

        // MARK: - Shared

        .target(
            name: "Shared",
            dependencies: ["SideKit"]
        ),

        .testTarget(
            name: "SharedTests",
            dependencies: ["Shared"]
        ),

        // MARK: - SideBackup

        .executableTarget(
            name: "SideBackup",
            dependencies: []
        ),

        // MARK: - SideDaemon

        .executableTarget(
            name: "SideDaemon",
            dependencies: [
				"Shared",
				.product(name: "AltSign", package: "AltSign"),
				.product(name: "LaunchAtLogin", package: "LaunchAtLogin"),
			]
        ),

        .testTarget(
            name: "SideDaemonTests",
            dependencies: ["SideDaemon"]
        ),

        // MARK: - SideStoreCore

        .target(
            name: "SideStoreCore",
            dependencies: [
				"Shared",
				.product(name: "Roxas", package: "Roxas"),
				.product(name: "AltSign", package: "AltSign"),
				.product(name: "KeychainAccess", package: "KeychainAccess"),
				.product(name: "SemanticVersion", package: "SemanticVersion"),
			],
			swiftSettings: [
				.unsafeFlags([
//					"--xcconfig-overrides", "AltStoreCore.xconfig"
				])
			]
        ),

        .testTarget(
            name: "SideStoreCoreTests",
            dependencies: ["SideStoreCore"]
        ),

		// MARK: - libfragmentzip
		.target(
			name: "libfragmentzip",
			dependencies: [],
			sources: [
				"libfragmentzip-source/libfragmentzip/libfragmentzip.c"
			],
			cSettings: [
				.headerSearchPath("libfragmentzip-source/libfragmentzip/include")
			]
		),

		.testTarget(
			name: "libfragmentzipTests",
			dependencies: ["libfragmentzip"]
		),
    ],
    swiftLanguageVersions: [.v5],
    cLanguageStandard: .c2x,
    cxxLanguageStandard: .cxx20
)

// MARK: - Helpers

func envBool(_ key: String) -> Bool {
    guard let value = ProcessInfo.processInfo.environment[key] else { return env[key, default: true] }
    let trueValues = ["1", "on", "true", "yes"]
    return trueValues.contains(value.lowercased())
}
