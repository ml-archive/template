import AdminPanel
import Bugsnag
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

internal func setupProviders(
    services: inout Services,
    config: inout Config,
    environment: Environment
) throws {
    // MARK: Vapor

    try services.register(FluentMySQLProvider())
    try services.register(LeafProvider())
    try services.register(RedisProvider())
    services.register(AppConfig.redis)
    services.register(RedisClientFactory())
    services.register(
        KeyedCache.self
    ) { container -> DatabaseKeyedCache<ConfiguredDatabase<RedisDatabase>> in
        try container.keyedCache(for: .redis)
    }

    // Admin Panel

    let adminPanelProvider = AdminPanelProvider<AdminPanelUser>(
        config: AppConfig.adminPanel(environment)
    )
    try services.register(adminPanelProvider)
    try services.register(NodesSSOProvider<AdminPanelUser>(
        config: AppConfig.nodesSSO(
            adminPanelProvider.middlewares.unsecure,
            environment: environment
        )
    ))

    // MARK: Mailgun

    services.register(
        Mailgun(
            apiKey: env(EnvironmentKey.Mailgun.apiKey, ""),
            domain: env(EnvironmentKey.Mailgun.domain, "")
        ),
        as: Mailgun.self
    )

    // MARK: Misc

    try services.register(JWTKeychainProvider<AppUser>(config: AppConfig.jwtKeychain))
    try services.register(NMetaProvider(config: AppConfig.nMeta))
    try services.register(ResetProvider<AppUser>(config: AppConfig.reset))
    services.register(BugsnagClient(AppConfig.bugsnag(environment)))
}
