import AdminPanel
import FluentMySQL
import JWTKeychain
import Leaf
import Mailgun
import NMeta
import NodesSSO
import Redis
import Reset
import Sugar
import Vapor
import Bugsnag

/// Called before your application initializes.
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    /// Register providers first
    try providers(&services, env)

    /// Register routes to the router
    services.register(Router.self) { container -> EngineRouter in
        let router = EngineRouter.default()
        try routes(router, container)
        return router
    }

    // MARK: Middlewares

    var middlewaresConfig = MiddlewareConfig()
    try middlewares(config: &middlewaresConfig)
    services.register(middlewaresConfig)

    // MARK: Databases

    var databasesConfig = DatabasesConfig()
    try databases(config: &databasesConfig)
    services.register(databasesConfig)

    // MARK: Migrations

    var migrationConfig = MigrationConfig()
    try migrate(migrations: &migrationConfig)
    services.register(migrationConfig)

    // MARK: Commands

    var commandsConfig = CommandConfig.default()
    commands(config: &commandsConfig)
    services.register(commandsConfig)

    // MARK: Configure

    // Use Redis for caching
    config.prefer(DatabaseKeyedCache<ConfiguredDatabase<RedisDatabase>>.self, for: KeyedCache.self)

    // MARK: Leaf tags
    // Look at boot.swift
}

// MARK: - Providers
private func providers(
    _ services: inout Services,
    _ environment: Environment
) throws {
    // MARK: Vapor

    try services.register(FluentMySQLProvider())
    try services.register(LeafProvider())
    try services.register(RedisProvider())
    services.register(Configs.redis)
    services.register(RedisClientFactory())
    services.register(
        KeyedCache.self
    ) { container -> DatabaseKeyedCache<ConfiguredDatabase<RedisDatabase>> in
        try container.keyedCache(for: .redis)
    }

    // MARK: Admin Panel

    let adminPanelProvider = AdminPanelProvider<AdminPanelUser>(
        config: Configs.adminPanel(environment)
    )
    try services.register(adminPanelProvider)
    try services.register(NodesSSOProvider<AdminPanelUser>(
        config: Configs.nodesSSO(adminPanelProvider.middlewares.unsecure, environment: environment))
    )

    // MARK: Mailgun

    services.register(
        Mailgun(
            apiKey: env(EnvironmentKey.Mailgun.apiKey, ""),
            domain: env(EnvironmentKey.Mailgun.domain, "")
        ),
        as: Mailgun.self
    )

    // MARK: Misc

    try services.register(JWTKeychainProvider<AppUser>(config: Configs.jwtKeychain))
    try services.register(NMetaProvider(config: Configs.nMeta))
    try services.register(ResetProvider<AppUser>(config: Configs.reset))
    services.register(BugsnagClient(Configs.bugsnag(environment)))
}
