import Vapor

final class TestRoutes: RouteCollection {
    func build(_ builder: RouteBuilder) {
        builder.get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        builder.get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        builder.get("info") { req in
            return req.description
        }

        builder.get("description") { req in return req.description }
    }
}


// MARK: EmptyInitializable
extension TestRoutes: EmptyInitializable {}