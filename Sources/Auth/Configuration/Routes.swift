import Vapor

public struct Routes: RouteCollection {
    public init() {}

    public func boot(routes: RoutesBuilder) throws {
        try routes.register(collection: AuthController())
    }
}
