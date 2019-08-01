import JWTKeychain
import Sugar

extension AppUser: Loginable {
    struct Login: Decodable, HasReadablePassword, HasReadableUsername {
        static let readablePasswordKey = \Login.password
        static let readableUsernameKey = \Login.email

        let email: String
        let password: String
    }
}
