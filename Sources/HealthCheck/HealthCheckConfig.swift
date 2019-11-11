import Vapor

// Endpoint configuration
public struct HealthCheckEndpoints {
    let health: String

    init(health: String) {
        self.health = health
    }

    public static var `default`: HealthCheckEndpoints {
        return .init(health: "/health")
    }
}

public struct HealthCheckConfig: Service {
    let endpoints: HealthCheckEndpoints

    public init(endpoints: HealthCheckEndpoints = .default) {
        self.endpoints = endpoints
    }
}
