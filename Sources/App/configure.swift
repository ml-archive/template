import Bugsnag
import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

public func configure(_ app: Application) throws {
    bugsnag(app)
    commands(app)
    middleware(app)
    migrations(app)
    try routes(app)
    signers(app)

    app.views.use(.leaf)

    try app.databases.use(.postgres(url: Environment.postgreSQLURL), as: .psql)

    app.mailgun.configuration = .init(apiKey: Environment.mailgunPassword)
    app.mailgun.defaultDomain = .init(Environment.mailgunDefaultDomain, Environment.mailgunRegion)
}
