import MySQL
import Redis
import Vapor

// MARK: HealthComponent conformance
// Extends database services with HealthComponent so we
// can generate a uniform response in the health API
extension MySQLDatabase: HealthComponent {
    public static var componentName: String { "mysql" }
    public static var componentType: String { "datastore" }
    public static var measurementName: String? { nil }

    public static func healthCheck(on request: Request) -> EventLoopFuture<Health.Check> {
        request.databaseConnection(to: .mysql).flatMap { database in
            database.raw("SHOW TABLES;").all().map { _ in
                Health.Check(self, status: .pass)
            }
        }.catchMap { error in
            Health.Check(
                self,
                status: .fail,
                output: error.localizedDescription
            )
        }
    }
}

extension RedisDatabase: HealthComponent {
    public static var componentName: String { "redis" }
    public static var componentType: String { "datastore" }
    public static var measurementName: String? { nil }

    public static func healthCheck(on request: Request) -> EventLoopFuture<Health.Check> {
        request.withNewConnection(to: .redis) { database in
            database.get("test", as: String.self).map { _ in
                Health.Check(self, status: .pass)
            }
        }.catchMap { error in
            Health.Check(
                self,
                status: .fail,
                output: error.localizedDescription
            )
        }
    }
}

// MARK: Router extension
public extension Router {
    func useHealthAPIRoutes(on container: Container) throws {
        let config: HealthCheckConfig = try container.make()
        get(config.endpoints.health) { container -> Future<Response> in
            let system = System([
                MySQLDatabase.self,
                RedisDatabase.self
            ])

            return system.health(on: container)
        }
    }
}
