import Vapor

func bugsnag(_ app: Application) {
    app.bugsnag.configuration = .init(
        apiKey: Environment.bugsnagAPIKey,
        releaseStage: app.environment.name,
        keyFilters: ["password", "email"]
    )
    app.bugsnag.users.add(AppUser.self)
}
