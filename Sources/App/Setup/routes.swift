import AdminPanel
import JWTKeychain
import Vapor

/// Register your application's routes here.
public func routes(_ router: Router, _ container: Container) throws {
    let jwtKeychain: JWTKeychainProvider<AppUser> = try container.make()
    let adminPanel: AdminPanelProvider<AdminPanelUser> = try container.make()

    // MARK: API
    // let unprotectedApi = router
    // let protectedApi = unprotectedApi.grouped(jwtKeychain.middlewares.accessMiddlewares)


    // MARK: Backend
    // let unprotectedBackend = router
    // let protectedBackend = unprotectedBackend.grouped(adminPanel.middlewares.secure)
}