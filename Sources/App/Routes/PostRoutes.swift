import Vapor

final class PostRoutes: RouteCollection {
    func build(_ builder: RouteBuilder) throws {
        try builder.resource("posts", PostController.self)
    }
}


// MARK: EmptyInitializable
extension PostRoutes: EmptyInitializable {}
