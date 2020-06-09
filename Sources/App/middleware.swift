import Bugsnag
import Vapor

func middleware(_ app: Application) {
    app.middleware = .init() // clear default middleware to enable inserting CORSMiddleware first
    app.middleware.use(CORSMiddleware())
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))
    app.middleware.use(BugsnagMiddleware())
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
}
