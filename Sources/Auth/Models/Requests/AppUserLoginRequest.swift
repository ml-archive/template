import Core
import Keychain
import Submissions
import User
import Vapor

struct AppUserLoginRequest: Codable, LoginRequest {
    typealias AccessKeychainConfig = AppUserAccessKeychainConfig
    typealias RefreshKeychainConfig = AppUserRefreshKeychainConfig

    static let hashedPasswordKey: KeyPath<AppUser, String> = \.hashedPassword

    let email: String
    let password: String

    func logIn(on request: Request) -> EventLoopFuture<AppUser> {
        request.repositories.appUser.findAppUserByEmail(email).unwrap(or: CoreError.incorrectCredentials)
    }
}
