import AdminPanel
import FluentMySQL
import Leaf
import NodesSSO
import Paginator
import Redis
import Storage
import Sugar
import Vapor

/// Called before your application initializes.
func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {

    // MARK: Load environment variables from .env file

    Environment.dotenv()

    // MARK: Providers

    try setUpProviders(services: &services, config: &config, environment: env)

    // MARK: Routes

    services.register(Router.self) { container -> EngineRouter in
        let router = EngineRouter.default()
        try routes(router, container)
        return router
    }

    // MARK: Middlewares

    var middlewaresConfig = MiddlewareConfig()
    try middleware(config: &middlewaresConfig)
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

    setUpRepositories(services: &services, config: &config)

    // MARK: Content

    var contentConfig = ContentConfig.default()
    try content(config: &contentConfig)
    services.register(contentConfig)

    // MARK: Commands

    var commandsConfig = CommandConfig.default()
    commands(config: &commandsConfig)
    services.register(commandsConfig)

    // MARK: Configure

    // use Redis for caching
    config.prefer(DatabaseKeyedCache<ConfiguredDatabase<RedisDatabase>>.self, for: KeyedCache.self)

    // set default pagination settings
    services.register(OffsetPaginatorConfig.current)

    // default to Leaf when rendering views
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)

    // MARK: Leaf tags

    var leafTagConfig = LeafTagConfig.default()
    try leafTags(config: &leafTagConfig)
    services.register(leafTagConfig)

    // MARK: Services

    #warning ("TODO: Remember to replace 'nodestemplate' with the name of the app.")
    let driver = try S3Driver(
        bucket: Sugar.env(EnvironmentKey.Storage.bucket, ""),
        accessKey: Sugar.env(EnvironmentKey.Storage.accessKey, ""),
        secretKey: Sugar.env(EnvironmentKey.Storage.secretKey, ""),
        pathTemplate: "/nodestemplate/#mimeFolder/#uuid.#fileExtension"
    )
    services.register(driver, as: NetworkDriver.self)
    Storage.cdnBaseURL = Sugar.env(EnvironmentKey.Storage.cdnPath, "http://127.0.0.1:8080")
}
