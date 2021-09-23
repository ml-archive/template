import Core
import Vapor

public struct AppUserMeResponse: Codable, Content {
    let id: UUID
}

public extension AppUserMeResponse {
    init(_ user: AppUser) throws {
        self.id = try user.requireID()
    }
}
