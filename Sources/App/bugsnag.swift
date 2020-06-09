import Vapor

func bugsnag(_ app: Application) {
    app.bugsnag.configuration = .init(
        apiKey: Environment.bugsnagAPIKey,
        releaseStage: app.environment.name,
        version: nil, // TODO: Environment.gitHash once available
        keyFilters: ["password", "email"]
    )
    app.bugsnag.users.use(AppUser.self)
}
