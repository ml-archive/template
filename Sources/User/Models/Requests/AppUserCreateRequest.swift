import Core
import Submissions
import Vapor

struct AppUserCreateRequest: Codable, CreateRequest {
    let name: String
    let email: String
    let password: String

    func create(on request: Request) -> EventLoopFuture<AppUser> {
        request.password.async.hash(password).map { hashedPassword in
            AppUser(
                name: self.name,
                email: self.email,
                hashedPassword: hashedPassword
            )
        }
    }
}

extension AppUserCreateRequest {
    static func validations(on request: Request) -> EventLoopFuture<Validations> {
        var validations = Validations()

        validations.add("password", is: .strongPassword)
        validations.add("email", is: .email)

        guard let email = try? request.content.get(String.self, at: "email") else {
            return request.eventLoop.future(validations)
        }
        
        return request.repositories.appUser.findAppUserByEmail(email).map { optionalUser in
            validations.add(
                "email",
                result: ValidatorResults.UniqueUser(isUniqueUser: optionalUser == nil)
            )

            return validations
        }
    }
}
