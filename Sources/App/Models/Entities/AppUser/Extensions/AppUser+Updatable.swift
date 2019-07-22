import JWTKeychain
import Sugar

extension AppUser: Updatable {
    struct Update: Decodable, HasUpdatableUsername, HasUpdatablePassword {
        static let oldPasswordKey = \Update.oldPassword
        static let updatablePasswordKey = \Update.password
        static let updatableUsernameKey = \Update.email

        let email: String?
        let name: String?
        let password: String?
        let oldPassword: String?

        var username: String? {
            return email
        }
    }

    func update(_ updated: Update) throws {
        if let email = updated.email {
            self.email = email
        }

        if let password = updated.password {
            self.password = try AppUser.hashPassword(password)
            self.passwordChangeCount += 1
        }

        if let name = updated.name {
            self.name = name
        }
    }
}
