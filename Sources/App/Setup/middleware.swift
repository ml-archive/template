import Bugsnag
import NMeta
import Submissions
import Vapor

func middleware(config: inout MiddlewareConfig) throws {
    // ⚠️ The CORSMiddleware needs to be before the ErrorMiddleware.
    config.use(CORSMiddleware(configuration: .current))
    config.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    config.use(SessionsMiddleware.self)
    config.use(NMetaMiddleware.self)
    // ⚠️ The BugsnagMiddleware needs to be the second to last middleware (right before
    // the FileMiddleware).
    config.use(BugsnagMiddleware.self)
    config.use(SubmissionsMiddleware())
    // ⚠️ The FileMiddleware needs to be the last middleware.
    config.use(FileMiddleware.self) // Serves files from `Public/` directory
}
