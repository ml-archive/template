import Vapor

protocol HealthIndicatable {
    static var healthId: String { get }
    static func isHealthy(on req: Request) -> EventLoopFuture<Health.Indicator>
}
