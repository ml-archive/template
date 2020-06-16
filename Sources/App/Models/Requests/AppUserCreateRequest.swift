import Submissions
import Vapor

struct AppUserCreateRequest: Codable, CreateRequest {
    let password: String

    func create(on request: Request) -> EventLoopFuture<AppUser> {
        request.password.async.hash(password).map { hashedPassword in
            AppUser(hashedPassword: hashedPassword)
        }
    }
}

extension AppUserCreateRequest {
    static func validations(on request: Request) -> EventLoopFuture<Validations> {
        var validations = Validations()

        validations.add("password", as: String.self, is: .strongPassword, required: true)
        validations.add("userID", as: String.self, is: .count(8...), required: true)

        let userID = try? request.content.get(UUID.self, at: "userID")
        return request.repositories.appUser.find(userID).map { optionalUser in
            validations.add(
                "userID",
                result: ValidatorResults
                    .UniqueUser(isUniqueUser: optionalUser == nil)
            )

            return validations
        }
    }
}
