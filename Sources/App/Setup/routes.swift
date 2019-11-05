import AdminPanel
import Vapor
import MySQL

/// Register your application's routes here.
func routes(_ router: Router, _ container: Container) throws {

    // MARK: robots.txt

    if !container.environment.isRelease {
        router.get("robots.txt") { _ in
            return """
            User-agent: *
            Disallow: /"
            """
        }
    }

    // MARK: Health
    
    router.get("health") { req -> Future<Response> in
        // return req.response(http: HTTPResponse(status: .ok))
        let sys = System([
            MySQLDatabase.self
        ])

        return sys.health(on: req)
    }

    // MARK: - Default routes

    try router.useAdminPanelRoutes(AdminPanelUser.self, on: container)
    try router.useNodesSSORoutes(AdminPanelUser.self, on: container)
    try router.useResetRoutes(AppUser.self, on: container)
    try router.useJWTKeychainRoutes(AppUser.self, on: container)

    // MARK: - Project specific routes
//    let adminPanel: AdminPanelMiddlewares = try container.make()
//    let jwtKeychain: JWTKeychainMiddlewares<AppUser> = try container.make()

    // MARK: API
//    let unprotectedApi = router
//    let protectedApi = unprotectedApi.grouped(jwtKeychain.accessMiddlewares)

    // MARK: Backend
//    let unprotectedBackend = router
//    let protectedBackend = unprotectedBackend.grouped(adminPanel.secure)
}
