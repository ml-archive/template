import Fluent
import JWTKeychain
import Reset
import Sugar
import Vapor

extension AppUser: JWTCustomPayloadKeychainUserType {
    typealias JWTPayload = ModelPayload<AppUser>
    typealias Login = UserLogin
    typealias Registration = UserRegistration
    typealias Update = UserUpdate
    typealias Public = UserPublic

    static let usernameKey: WritableKeyPath<AppUser, String> = \.email
    static let passwordKey: WritableKeyPath<AppUser, String> = \.password

    struct UserLogin: HasReadablePassword, HasReadableUsername {
        static let readablePasswordKey = \UserLogin.password
        static let readableUsernameKey = \UserLogin.email

        let email: String
        let password: String
    }

    struct UserPublic: Content {
        let email: String
        let name: String
    }

    struct UserRegistration: HasReadablePassword, HasReadableUsername {
        static let readablePasswordKey = \UserRegistration.password
        static let readableUsernameKey = \UserRegistration.email

        let email: String
        let name: String
        let customerIds: String
        let password: String
    }

    struct UserUpdate: Decodable, HasUpdatableUsername, HasUpdatablePassword {
        static let oldPasswordKey = \UserUpdate.oldPassword
        static let updatablePasswordKey = \UserUpdate.password
        static let updatableUsernameKey = \UserUpdate.email

        let email: String?
        let name: String?
        let password: String?
        let oldPassword: String?

        var username: String? {
            return email
        }
    }

    convenience init(_ registration: UserRegistration) throws {
        try self.init(
            email: registration.email,
            name: registration.name,
            password: AppUser.hashPassword(registration.password)
        )
    }

    func convertToPublic(on req: Request) throws -> Future<UserPublic> {
        return req.future(UserPublic(email: email, name: name))
    }

    func update(with updated: UserUpdate) throws {
        if let email = updated.email {
            self.email = email
        }

        if let password = updated.password {
            self.password = try AppUser.hashPassword(password)
            self.passwordChangeCount = self.passwordChangeCount + 1
        }

        if let name = updated.name {
            self.name = name
        }
    }
}
