import Auth
import Core
import Fluent
import JWT
import User
import Vapor

extension Vapor.Routes {
    func configure() throws {
        // Health endpoint. Required for AWS.
        get("health") { _ in "200 OK" }

        let apiV1Routes = grouped("api", "v1")

        let appRoutes = apiV1Routes.grouped("app")
        try appRoutes.grouped("auth").register(collection: Auth.Routes())
        try appRoutes.grouped("users").register(collection: User.Routes.Unprotected())

        let protectedApp = appRoutes
            .grouped(Auth.AppUserAccessKeychainConfig.authenticator, AppUser.guardMiddleware())

        try protectedApp.grouped("users").register(collection: User.Routes.Protected())
    }
}
