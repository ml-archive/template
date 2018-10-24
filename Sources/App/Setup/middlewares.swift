import Bugsnag
import NMeta
import Vapor

public func middlewares(config: inout MiddlewareConfig) throws {
    config.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    config.use(SessionsMiddleware.self)
    config.use(NMetaMiddleware.self)
    // ⚠️ The BugsnagMiddleware needs to be the second to last middleware (right before
    // the FileMiddleware).
    config.use(BugsnagClient.self)
    // ⚠️ The FileMiddleware needs to be the last middleware.
    config.use(FileMiddleware.self) // Serves files from `Public/` directory
}
