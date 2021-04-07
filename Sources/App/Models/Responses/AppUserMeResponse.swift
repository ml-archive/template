import Vapor

struct AppUserMeResponse: Codable {
    let id: UUID
}

extension AppUserMeResponse {
    init(_ user: AppUser) throws {
        self.id = try user.requireID()
    }
}
