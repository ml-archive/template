import Vapor

public func configure(_ app: Application) throws {
    bugsnag(app)
    commands(app)
    mail(app)
    middleware(app)
    migrations(app)
    signers(app)
    try databases(app)
    try routes(app)
    app.sessions.use(.memory)
}
