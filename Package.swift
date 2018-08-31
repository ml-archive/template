// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "NodesTemplate",
    dependencies: [
        // Vapor
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/redis.git", from: "3.0.0"),

        // Nodes
        .package(url: "https://github.com/nodes-vapor/jwt-keychain.git", from: "1.0.0-beta"),
        .package(url: "https://github.com/nodes-vapor/sugar.git", from: "3.0.0-beta"),
        .package(url: "https://github.com/nodes-vapor/n-meta.git", from: "3.0.0-beta"),
        .package(url: "https://github.com/nodes-vapor/admin-panel.git", .upToNextMinor(from:"2.0.0-beta")),
        .package(url: "https://github.com/nodes-vapor/submissions.git", from: "1.0.0-beta"),
        .package(url: "https://github.com/nodes-vapor/nodes-sso.git", from: "1.0.0-beta"),
        .package(url: "https://github.com/nodes-vapor/paginator.git", .branch("vapor-3")),

        // 3rd Party

    ],
    targets: [
        .target(name: "App", dependencies: [
            "Vapor",
            "FluentMySQL",
            "Redis",
            "JWTKeychain",
            "Sugar",
            "NMeta",
            "AdminPanel",
            "Submissions",
            "Mailgun",
            "NodesSSO",
            "Paginator"
        ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)
