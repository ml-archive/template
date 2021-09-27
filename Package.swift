// swift-tools-version:5.5
import PackageDescription

let typeCheckingLimit = 175
let warnAboutLongTypeChecking = SwiftSetting.unsafeFlags(
    [
        "-Xfrontend", "-warn-long-function-bodies=\(typeCheckingLimit)",
        "-Xfrontend", "-warn-long-expression-type-checking=\(typeCheckingLimit)"
    ],
    .when(configuration: .debug)
)

let package = Package(
    name: "monstar-lab-template",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: [
        .package(url: "https://github.com/nodes-vapor/bugsnag.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/nodes-vapor/keychain.git", from: "2.0.0-rc"),
        .package(url: "https://github.com/nodes-vapor/submissions.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor-community/mailgun.git", from: "5.0.0"),
        .package(url: "https://github.com/nodes-vapor/n-meta.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0")
    ],
    targets: [
        .executableTarget(
            name: "Run",
            dependencies: [
                "App",
            ]
        ),
        .target(
            name: "App",
            dependencies: [
                "Auth",
                "Core",
                "User",
                .product(name: "Bugsnag", package: "bugsnag"),
                .product(name: "Keychain", package: "keychain"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "Mailgun", package: "mailgun"),
                .product(name: "NMeta", package: "n-meta"),
                .product(name: "Submissions", package: "submissions"),
                .product(name: "Vapor", package: "vapor"),
            ],
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release)),
                warnAboutLongTypeChecking
            ]
        ),
        .target(
            name: "Auth",
            dependencies: [
                "Core",
                "User",
                .product(name: "Keychain", package: "keychain"),
            ],
            swiftSettings: [
                warnAboutLongTypeChecking
            ]
        ),
        .target(
            name: "Core",
            dependencies: [
                .product(name: "Bugsnag", package: "bugsnag"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Keychain", package: "keychain"),
                .product(name: "Vapor", package: "vapor"),
            ],
            swiftSettings: [
                warnAboutLongTypeChecking
            ]
        ),
        .target(
            name: "User",
            dependencies: [
                "Core",
            ],
            swiftSettings: [
                warnAboutLongTypeChecking
            ]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                "App",
                .product(name: "XCTVapor", package: "vapor"),
            ],
            swiftSettings: [
                warnAboutLongTypeChecking
            ]
        ),
    ]
)
