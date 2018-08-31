import AdminPanel
import JWTKeychain
import Vapor

/// Register your application's routes here.
public func routes(
    _ router: Router,
    adminPanelMiddlewares: AdminPanelMiddlewares,
    jwtKeychainMiddlewares: JWTKeychainMiddlewares
) throws {
    // MARK: API
    let unprotectedApi = router
    let protectedApi = unprotectedApi.grouped(jwtKeychainMiddlewares.accessMiddlewares)


    // MARK: Backend
    let unprotectedBackend = router
    let protectedBackend = unprotectedBackend.grouped(adminPanelMiddlewares.secure)
}
