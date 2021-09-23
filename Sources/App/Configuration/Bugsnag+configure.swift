import Bugsnag
import Core
import Vapor

extension Application.Bugsnag {
    func configure() {
        configuration = .init(
            apiKey: Environment.Bugsnag.apiKey,
            releaseStage: application.environment.name,
            keyFilters: ["password", "email"]
        )
        users.add(AppUser.self)
    }
}
