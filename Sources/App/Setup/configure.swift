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
    // MARK: Providers

    try setupProviders(services: &services, config: &config, environment: env)

    // MARK: Routes

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

    // MARK: Repositories

    setupRepositories(services: &services, config: &config)

    // MARK: Content

    var contentConfig = ContentConfig.default()
    try content(config: &contentConfig)
    services.register(contentConfig)

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
