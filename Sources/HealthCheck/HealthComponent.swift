import Vapor

// MARK: Protocol
// Conform to enable a component in the health api response
public protocol HealthComponent {
    // A system component identifier eg. mysql or system
    static var componentName: String { get }

    // A system component type eg. datastore, system, etc.
    static var componentType: String { get }

    // An optional descriptive name of the type of masurement made eg. connection or uptime
    static var measurementName: String? { get }

    // The function that does the heath check on a given service
    static func healthCheck(on request: Request) -> EventLoopFuture<Health.Check>
}
