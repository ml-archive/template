import Foundation
import JWT
import Keychain

struct AppUserAccessKeychainConfig: KeychainConfig {
    typealias JWTPayload = AppUserJWTPayload

    static var jwkIdentifier: JWKIdentifier = "access"

    let expirationTimeInterval: TimeInterval
}
