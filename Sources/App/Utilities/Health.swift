// Health check API
// see https://inadarei.github.io/rfc-healthcheck/ for more info

import Vapor
import MySQL
import Redis

// MARK: Protocol

protocol HealthComponent {
    // A system component identifier eg. mysql or system
    static var componentName: String { get }

    // A system component type eg. datastore, system, etc.
    static var componentType: String { get }

    // An optional descriptive name of the type of masurement made eg. connection or uptime
    static var measurementName: String? { get }

    // The function that does the heath check on a given service
    static func healthCheck(on request: Request) -> EventLoopFuture<Health.Check>
}

// MARK: HealthComponent Extensions

// Extends database services with HealthComponent so we
// can generate a uniform response in the health API

extension MySQLDatabase: HealthComponent {
    static var componentName: String { "mysql" }
    static var componentType: String { "datastore" }
    static var measurementName: String? { nil }

    static func healthCheck(on request: Request) -> EventLoopFuture<Health.Check> {
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
    static var componentName: String { "redis" }
    static var componentType: String { "datastore" }
    static var measurementName: String? { nil }

    static func healthCheck(on request: Request) -> EventLoopFuture<Health.Check> {
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

// MARK: Health

// Helpers for the Health API

struct Health {
    // Health status indication options
    enum Status: String {
        case pass
        case fail
        case warn
    }

    // Health API response type
    struct Check: Content {
        let componentName: String
        let componentType: String
        let measurementName: String?
        let status: String
        let output: String?
        let time: String?

        var key: String {
            if let measurement = measurementName  {
                return "\(self.componentName):\(measurement)"
            } else {
                return self.componentName
            }
        }

        init(
            _ healthComponent: HealthComponent.Type,
            status: Health.Status,
            output: String? = nil
        ) {
            self.componentName = healthComponent.componentName
            self.componentType = healthComponent.componentType
            self.measurementName = healthComponent.measurementName
            self.status = status.rawValue
            self.output = output
            self.time = DateFormatters.iso8601.string(from: Date())
        }
    }

    // Health API response type

    struct Response: Content {
        let status: String
        let checks: [String: [Check]]
        let notes: [String]
        let version: Int
        let releaseId: String

        init(
            status: Status,
            checks: [Check],
            version: Int = 1,
            releaseId: String = "1.0.0"
        ) {
            self.status = status.rawValue

            self.checks = checks.reduce([:], { (result, indicator) in
                var result = result
                let key = indicator.key
                result[key, default: []].append(indicator)
                return result
            })

            self.notes = [
                "Checks ability to handle requests",
                "Checks connection to mysql",
                "Checks connection to redis"
            ]

            self.version = version
            self.releaseId = releaseId
        }
    }
}

// MARK: System

struct System {
    // System components that should respond for proper health check
    var components: [HealthComponent.Type]

    // Response headers
    let headers: HTTPHeaders = HTTPHeaders([
        ("Content-Type", "application/health+json"),
        ("Cache-Control", "max-age=3600"),
        ("Connection", "close")
    ])

    init(_ components: [HealthComponent.Type]) {
        self.components = components
    }

    func health(on request: Request) -> EventLoopFuture<Response> {
        self.components.map { $0.healthCheck(on: request) }
            .flatten(on: request)
            .flatMap(to: Response.self) { results in
                var responseStatus: HTTPStatus = .ok
                var healthStatus: Health.Status = .pass

                results.forEach { check in
                    if check.status == Health.Status.warn.rawValue {
                        healthStatus = .warn
                    }
                }

                results.forEach { check in
                    if check.status == Health.Status.fail.rawValue {
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

// MARK: Router extension
public extension Router {
    func useHealthAPIRoutes(on container: Container) throws {
        get(Endpoint.health) { container -> Future<Response> in
            let system = System([
                MySQLDatabase.self,
                RedisDatabase.self
            ])

            return system.health(on: container)
        }
    }
}
