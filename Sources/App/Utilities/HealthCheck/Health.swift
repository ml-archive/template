// Health check API
// see https://inadarei.github.io/rfc-healthcheck/ for more info

import Vapor
import MySQL
import Redis

// MARK: Protocol

protocol HealthComponent {
    // A system component identifier eg. mysql:connections
    static var componentName: String { get }

    // A system component type eg. datastore, system, etc.
    static var componentType: String { get }

    // A descriptive name of the type of masurement made
    static var measurementName: String? { get }

    // The function that does the heath check on a given service
    static func isHealthy(on request: Request) -> EventLoopFuture<Health.Indicator>
}

// MARK: Extensions

// Extends database services with HealthComponent so we
// can generate a uniform response in the health API

extension MySQLDatabase: HealthComponent {
    static var componentName: String { "mysql" }
    static var componentType: String { "datastore" }
    static var measurementName: String? { "connection" }

    static func isHealthy(on request: Request) -> EventLoopFuture<Health.Indicator> {
        return request.databaseConnection(to: .mysql).flatMap { database in
            return database.raw("SHOW TABLES;").all().map { result in
                return Health.Indicator(
                    self,
                    status: .pass
                )
            }
        }.catchMap { error in
            return Health.Indicator(
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
    static var measurementName: String? { "connection" }

    static func isHealthy(on request: Request) -> EventLoopFuture<Health.Indicator> {
        return request.withNewConnection(to: .redis) { database in
            return database.get("test", as: String.self).map { _ in
                return Health.Indicator(
                    self,
                    status: .pass
                )
            }
        }.catchMap { error in
            return Health.Indicator(
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
    struct Indicator: Content {
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
            _ h: HealthComponent.Type,
            status: Health.Status,
            output: String? = nil
        ) {
            self.componentName = h.componentName
            self.componentType = h.componentType
            self.measurementName = h.measurementName
            self.status = status.rawValue
            self.output = output
            self.time = DateFormatters.iso8601.string(from: Date())
        }
    }

    struct HealthResponse: Content {
        let status: String
        let checks: [String:[Indicator]]
        let notes: [String]
        let version: Int = 1
        let releaseId: String = "1.0.0"

        init(status: String, checks: [Indicator]) {
            self.status = status
            self.checks = checks.reduce([:], { (result, indicator) in
                var result = result
                let key = indicator.key
                result[key, default: []].append(indicator)
                return result
            })
            self.notes = [
                "Checks request handling",
                "Checks mysql connections",
                "Checks redis connections"
            ]
        }
    }
}

// MARK: System

struct System {
    // System components that should respond for proper health check
    var components: [HealthComponent.Type]

    // Response headers
    let headers: HTTPHeaders = HTTPHeaders([
        ("Content-Type","application/health+json"),
        ("Cache-Control","max-age=3600"),
        ("Connection","close")
    ])

    init(_ components: [HealthComponent.Type]) {
        self.components = components
    }

    func health(on request: Request) -> EventLoopFuture<Response> {
        return self.components.map { $0.isHealthy(on: request) }
            .flatten(on: request)
            .flatMap(to: Response.self) { results in
                var responseStatus: HTTPStatus = .ok
                var healthStatus: Health.Status = .pass

                results.forEach { indicator in
                    if indicator.status == Health.Status.warn.rawValue {
                        healthStatus = .warn
                    }
                }

                results.forEach { indicator in
                    if indicator.status == Health.Status.fail.rawValue {
                        responseStatus = .internalServerError
                        healthStatus = .fail
                    }
                }

                return Health.HealthResponse(
                    status: healthStatus.rawValue,
                    checks: results
                ).encode(
                    status: responseStatus,
                    headers: self.headers,
                    for: request
                )
            }
    }
}
