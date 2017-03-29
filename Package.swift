import PackageDescription

let vaporBeta = Version(2,0,0, prereleaseIdentifiers: ["beta"])

let package = Package(
    name: "NodesVaporApp",
    targets: [
        Target(name: "App", dependencies: ["AppLogic"])
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", vaporBeta)
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources"
    ]
)
