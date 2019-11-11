// Health check API
// see https://inadarei.github.io/rfc-healthcheck/ for more info
import Vapor

// MARK: Health
// Structs for generating the Health API response
public struct Health {
    // Health status indication options
    enum Status: String {
        case pass
        case fail
        case warn
    }

    // Health API response type
    public struct Check: Content {
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
