import Vapor

struct UserSessionAuthenticator: SessionAuthenticator {
    typealias User = AppUser

    func authenticate(sessionID: String, for request: Request) -> EventLoopFuture<Void> {
        request.repositories.appUser
            .find(UUID(sessionID))
            .map { $0.map(request.auth.login) }
    }
}
