import Vapor

// MARK: System
public struct System {
    // System components that should respond for proper health check
    var components: [HealthComponent.Type]

    // Response headers
    let headers: HTTPHeaders = HTTPHeaders([
        ("Content-Type", "application/health+json"),
        ("Cache-Control", "max-age=3600"),
        ("Connection", "close")
    ])

    public init(_ components: [HealthComponent.Type]) {
        self.components = components
    }

    public func health(on request: Request) -> EventLoopFuture<Response> {
        self.components.map { $0.healthCheck(on: request) }
            .flatten(on: request)
            .flatMap(to: Response.self) { results in
                var responseStatus: HTTPStatus = .ok
                var healthStatus: Health.Status = .pass

                results.forEach { check in
                    if check.status == Health.Status.warn {
                        healthStatus = .warn
                    }
                }

                results.forEach { check in
                    if check.status == Health.Status.fail {
                        responseStatus = .internalServerError
                        healthStatus = .fail
                    }
                }

                return Health.Response(
                    status: healthStatus,
                    checks: results
                ).encode(
                    status: responseStatus,
                    headers: self.headers,
                    for: request
                )
            }
    }
}
