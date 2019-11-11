// Health check API
// see https://inadarei.github.io/rfc-healthcheck/ for more info
import Vapor

// MARK: Health
// Structs for generating the Health API response
public struct Health {
    // Health status indication options
    enum Status: String, Equatable, Content {
        case pass
        case fail
        case warn
    }

    // Health API response type
    public struct Check: Content {
        var componentName: String = ""
        let componentType: String
        var measurementName: String? = ""
        let status: Status
        let output: String?
        let time: String?
        var note: String = ""

        var key: String {
            if let measurement = measurementName  {
                return "\(self.componentName):\(measurement)"
            } else {
                return self.componentName
            }
        }

        enum CodingKeys: String, CodingKey {
            case status
            case time
            case componentType
            case output
        }

        init(
            _ healthComponent: HealthComponent.Type,
            status: Health.Status,
            output: String? = nil
        ) {
            self.componentName = healthComponent.componentName
            self.componentType = healthComponent.componentType
            self.measurementName = healthComponent.measurementName
            self.status = status
            self.output = output
            self.time = DateFormatters.iso8601.string(from: Date())
            self.note = healthComponent.note
        }
    }

    // Health API response type
    struct Response: Content {
        let status: Status
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
            self.status = status

            self.checks = checks.reduce([:], { (result, check) in
                var result = result
                let key = check.key
                result[key, default: []].append(check)
                return result
            })

            self.notes = checks.map { $0.note }

            self.version = version
            self.releaseId = releaseId
        }
    }
}
