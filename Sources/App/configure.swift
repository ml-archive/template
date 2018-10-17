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
    let (adminPanelMiddlewares, jwtKeychainMiddlewares) = try providers(&services, env)

    /// Register routes to the router
    try routes(
        &services,
        adminPanelMiddlewares: adminPanelMiddlewares,
        jwtKeychainMiddlewares: jwtKeychainMiddlewares
    )

    /// Register middleware
    middlewares(&services)

    // Configure a MySQL database
    try databases(&services)

    // Configure migrations
    migrations(&services)

    // Configure commands
    commands(&services)

    // Configure
    configure(&config)

    // Leaf tags
    // Look at boot.swift
}

// MARK: Providers
private func providers(
    _ services: inout Services,
    _ environment: Environment
) throws -> (AdminPanelMiddlewares, JWTKeychainMiddlewares) {
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

    let adminPanelProvider = AdminPanelProvider<AdminPanelUser>(
        config: Configs.adminPanel(environment)
    )
    try services.register(adminPanelProvider)

    try services.register(NMetaProvider(config: Configs.nMeta))

    let jwtKeychainProvider = JWTKeychainProvider<AppUser>(config: Configs.jwtKeychain)
    try services.register(jwtKeychainProvider)

    let passwordResetProvider = ResetProvider<AppUser>(config: Configs.reset)
    try services.register(passwordResetProvider)

    let mailgun = Mailgun(
        apiKey: env(EnvironmentKey.Mailgun.apiKey, ""),
        domain: env(EnvironmentKey.Mailgun.domain, "")
    )
    services.register(mailgun, as: Mailgun.self)

    try services.register(NodesSSOProvider<AdminPanelUser>(
        config: Configs.nodesSSO(adminPanelProvider.middlewares.unsecure, environment: environment))
    )

    // Register provider
    let bugsnagConfig: BugsnagConfig = BugsnagConfig(
        apiKey: env(EnvironmentKey.Bugsnag.key, ""),
        releaseStage: environment.name
    )
    services.register(BugsnagClient(bugsnagConfig))

    return (adminPanelProvider.middlewares, jwtKeychainProvider.middlewares)
}

// MARK: Databases
private func databases(_ services: inout Services) throws {
    let mysql = MySQLDatabase(config: Configs.mysql)

    // Register the configured MySQL database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: mysql, as: .mysql)
    databases.add(database: RedisDatabase.self, as: .redis)
    services.register(databases)
}

// MARK: Migrations
private func migrations(_ services: inout Services) {
    var migrations = MigrationConfig()

    services.register(migrations)
}

// MARK: Middlewares
private func middlewares(_ services: inout Services) {
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self)
    middlewares.use(NMetaMiddleware.self)
    // ⚠️ The BugsnagMiddleware needs to be the second to last middleware (right before
    // the FileMiddleware).
    middlewares.use(BugsnagClient.self)
    // ⚠️ The FileMiddleware needs to be the last middleware.
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    services.register(middlewares)
}

// MARK: Routes
private func routes(
    _ services: inout Services,
    adminPanelMiddlewares: AdminPanelMiddlewares,
    jwtKeychainMiddlewares: JWTKeychainMiddlewares
) throws {
    let router = EngineRouter.default()
    try routes(
        router,
        adminPanelMiddlewares: adminPanelMiddlewares,
        jwtKeychainMiddlewares: jwtKeychainMiddlewares
    )
    services.register(router, as: Router.self)
}

// MARK: Commands
private func commands(_ services: inout Services) {
    var commands = CommandConfig.default()
    commands.use(
        SeederCommand<AdminPanelUser>(databaseIdentifier: .mysql),
        as: "adminpanel:user-seeder"
    )

    services.register(commands)
}

// MARK: Configuration
private func configure(_ config: inout Config) {
    config.prefer(DatabaseKeyedCache<ConfiguredDatabase<RedisDatabase>>.self, for: KeyedCache.self)
}
