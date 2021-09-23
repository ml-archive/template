import Vapor

extension Request {
    public struct Repositories {
        let request: Request

        public var appUser: AppUserRepository {
            request.application.repositories.appUser(request.db)
        }
    }

    public var repositories: Repositories { .init(request: self) }
}
