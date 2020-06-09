import Vapor

struct AppUserMeResponse: Content {
    let id: String
}

extension AppUserMeResponse {
    init(_ user: AppUser) throws {
        self.id = try user.requireID()
    }
}
