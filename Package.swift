// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "nodes-template",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: [
        .package(url: "https://github.com/autimatisering/IkigaJSON.git", from: "2.0.0"),
        .package(url: "https://github.com/nodes-vapor/bugsnag.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/nodes-vapor/keychain.git", from: "2.0.0-rc"),
        .package(url: "https://github.com/nodes-vapor/submissions.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor-community/VaporMailgunService.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Bugsnag", package: "bugsnag"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "IkigaJSON", package: "IkigaJSON"),
                .product(name: "Keychain", package: "keychain"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "Mailgun", package: "VaporMailgunService"),
                .product(name: "Submissions", package: "submissions"),
                .product(name: "Vapor", package: "vapor"),
            ],
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .target(name: "Run", dependencies: [.target(name: "App")]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
