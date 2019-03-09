import JWTKeychain
import Reset
import Sugar
import Vapor

extension AppUser: JWTKeychainUserType {
    typealias JWTPayload = ModelPayload<AppUser>
}
