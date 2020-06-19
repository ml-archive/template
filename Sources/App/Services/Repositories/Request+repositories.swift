import Vapor

extension Request {
    struct Repositories {
        let request: Request

        var appUser: AppUserRepository {
            request.application.repositories.appUser(request.db)
        }
    }

    var repositories: Repositories { .init(request: self) }
}
