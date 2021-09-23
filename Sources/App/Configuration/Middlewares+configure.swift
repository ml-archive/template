import Bugsnag
import NMeta
import Vapor

extension Middlewares {
    mutating func configure(_ application: Application) {
        let corsMiddleware = CORSMiddleware(configuration: .init(
            allowedOrigin: .originBased,
            allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
            allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .init("N-Meta")]
        ))
        use(corsMiddleware, at: .beginning)
        use(ErrorMiddleware.customize(environment: application.environment))
        use(NMetaMiddleware())
        use(BugsnagMiddleware())
    }
}
