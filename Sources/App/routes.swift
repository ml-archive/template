import Fluent
import JWT
import Vapor

func routes(_ app: Application) throws {
    // Health endpoint. Required for AWS.
    app.get("health") { _ in "200 OK" }

    let apiV1Routes = app.grouped("api", "v1")

    let appRoutes = apiV1Routes.grouped("app")
    try appRoutes.grouped("users").register(collection: AppUserController())
}
