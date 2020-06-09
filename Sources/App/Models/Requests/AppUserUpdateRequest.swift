import Submissions
import Vapor

struct AppUserUpdateRequest: Codable, UpdateRequest {
    let password: String

    static func find(on request: Request) -> EventLoopFuture<AppUser> {
        Model.find(on: request)
    }

    func update(_ user: AppUser, on request: Request) -> EventLoopFuture<AppUser> {
        request.password.async.hash(password).map { hashedPassword in
            user.hashedPassword = hashedPassword
        }.transform(to: user)
    }
}

extension AppUserUpdateRequest {
    static func validations(
        for model: AppUser,
        on request: Request
    ) -> EventLoopFuture<Validations> {
        var validations = Validations()
        validations.add("password", is: .strongPassword)
        return request.eventLoop.future(validations)
    }
}
