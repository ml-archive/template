import MySQL
import Vapor

extension MySQLDatabase: HealthIndicatable {
    static var healthId: String { "mysql" }

    static func isHealthy(on request: Request) -> EventLoopFuture<Health.Indicator> {
        return request.databaseConnection(to: .mysql).flatMap { database in
            return database.raw("SHOW TABLES;").all().map { result in
                return Health.Indicator(id: self.healthId, status: Health.Status.ready.rawValue)
            }
        }.catchMap { _ in
            return Health.Indicator(id: self.healthId, status: Health.Status.notReady.rawValue)
        }
    }
}

struct Health {
    enum Status: String {
        case notReady
        case ready
    }

    struct Indicator: Content {
        let id: String
        let status: String
    }
}

struct System {
    var components: [HealthIndicatable.Type]

    init(_ components: [HealthIndicatable.Type]) {
        self.components = components
    }

    func health(on request: Request) -> EventLoopFuture<Response> {
        return self.components.map { $0.isHealthy(on: request) }
            .flatten(on: request)
            .flatMap(to: Response.self) { results in
                var status: HTTPStatus = .ok

                results.forEach { indicator in
                    if indicator.status == Health.Status.notReady.rawValue {
                        status = .internalServerError
                    }
                }

                return results.encode(status: status, for: request)
            }
    }
}
