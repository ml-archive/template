import Foundation
import Keychain
import JWT

struct AppUserAccessKeychainConfig: KeychainConfig {
    typealias JWTPayload = AppUserJWTPayload

    static var jwkIdentifier: JWKIdentifier = "access"

    let expirationTimeInterval: TimeInterval
}
