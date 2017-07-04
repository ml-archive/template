import PackageDescription

let package = Package(
    name: "VaporApp",
    targets: [
        Target(name: "App"),
        Target(name: "Run", dependencies: ["App"]),
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 2),
        .Package(url: "https://github.com/vapor/fluent-provider.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor/mysql-provider.git", majorVersion: 2),
        .Package(url: "https://github.com/vapor/redis-provider.git", majorVersion: 2),
        .Package(url: "https://github.com/nodes-vapor/bugsnag.git", majorVersion: 1),
        .Package(url: "https://github.com/nodes-vapor/sugar", majorVersion: 2)
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
    ]
)
