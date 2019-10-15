import JWTKeychain
import Reset

extension AppUser: JWTKeychainUserType {
    typealias JWTPayload = ModelPayload<AppUser>
}
