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
    services.register(RedisClientConfig.current)
    services.register(RedisClientFactory())
    services.register(
        KeyedCache.self
    ) { container -> DatabaseKeyedCache<ConfiguredDatabase<RedisDatabase>> in
        try container.keyedCache(for: .redis)
    }

    // Admin Panel

    let adminPanelProvider = AdminPanelProvider<AdminPanelUser> { _ in .current(environment) }
    try services.register(adminPanelProvider)
    try services.register(NodesSSOProvider<AdminPanelUser> { container in
        let adminPanelMiddlewares: AdminPanelMiddlewares = try container.make()
        return NodesSSOConfig.current(
            adminPanelMiddlewares.unsecure,
            environment: environment
        )
    })

    // MARK: Mailgun

    services.register(
        Mailgun(
            apiKey: env(EnvironmentKey.Mailgun.apiKey, ""),
            domain: env(EnvironmentKey.Mailgun.domain, "")
        ),
        as: Mailgun.self
    )

    // MARK: Misc

    try services.register(JWTKeychainProvider<AppUser>(configFactory: JWTKeychainConfig.current))
    try services.register(NMetaProvider(config: .current))
    try services.register(ResetProvider<AppUser>(configFactory: ResetConfig.current))
    try services.register(BugsnagProvider(config: .current(environment)))
}
