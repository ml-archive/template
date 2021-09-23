import Vapor

public struct Routes {
    public struct Protected: RouteCollection {
        public init() {}

        public func boot(routes: RoutesBuilder) throws {
            try routes.register(collection: AppUserController.Protected())
        }
    }

    public struct Unprotected: RouteCollection {
        public init() {}

        public func boot(routes: RoutesBuilder) throws {
            try routes.register(collection: AppUserController.Unprotected())
        }
    }
}
