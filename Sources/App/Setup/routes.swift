import AdminPanel
import JWTKeychain
import Vapor

/// Register your application's routes here.
public func routes(_ router: Router, _ container: Container) throws {
    if !container.environment.isRelease {
        router.get("robots.txt") { _ in
            return """
            User-agent: *
            Disallow: /"
            """
        }
    }

    // MARK: - Default routes

    try router.useAdminPanelRoutes(AdminPanelUser.self, on: container)
    try router.useNodesSSORoutes(AdminPanelUser.self, on: container)
    try router.useResetRoutes(AppUser.self, on: container)
    try router.useJWTKeychainRoutes(AppUser.self, on: container)

    // MARK: - Project specific routes

    // let jwtKeychain: AdminPanelMiddlewares = try container.make()
    // let adminPanel: AdminPanelMiddlewares = try container.make()

    // MARK: API
    // let unprotectedApi = router
    // let protectedApi = unprotectedApi.grouped(jwtKeychain.middlewares.accessMiddlewares)

    // MARK: Backend
    // let unprotectedBackend = router
    // let protectedBackend = unprotectedBackend.grouped(adminPanel.middlewares.secure)
}
