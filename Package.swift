// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "NodesTemplate",
    dependencies: [
        // Vapor
        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/redis.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // Nodes
        .package(url: "https://github.com/nodes-vapor/admin-panel.git", from:"2.0.0-rc"),
        .package(url: "https://github.com/nodes-vapor/bugsnag.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/nodes-vapor/jwt-keychain.git", from: "1.0.0-rc"),
        .package(url: "https://github.com/nodes-vapor/n-meta.git", from: "3.0.0-beta"),
        .package(url: "https://github.com/nodes-vapor/nodes-sso.git", from: "1.0.0-rc"),
        .package(url: "https://github.com/nodes-vapor/paginator.git", from: "3.2.0"),
        .package(url: "https://github.com/nodes-vapor/storage.git", from: "1.0.0-beta"),
        .package(url: "https://github.com/nodes-vapor/submissions.git", from: "2.0.0-rc"),
        .package(url: "https://github.com/nodes-vapor/sugar.git", from: "4.0.0-rc"),

        // 3rd Party
        .package(url: "https://github.com/twof/VaporMailgunService.git", from: "1.1.0"),
    ],
    targets: [
        .target(name: "App", dependencies: [
            "AdminPanel",
            "Bugsnag",
            "FluentMySQL",
            "JWTKeychain",
            "Mailgun",
            "NMeta",
            "NodesSSO",
            "Paginator",
            "Redis",
            "Storage",
            "Submissions",
            "Sugar",
            "Vapor"
        ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

