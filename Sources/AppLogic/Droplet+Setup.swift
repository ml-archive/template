import Vapor

public func setup(_ drop: Droplet) throws {
    //FIXME: Remove after setting up project.
    drop.get("test") { _ in return "Hello, World!" }
}
