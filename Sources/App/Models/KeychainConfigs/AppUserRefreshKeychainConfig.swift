import Foundation
import JWT
import Keychain

struct AppUserRefreshKeychainConfig: KeychainConfig {
    typealias JWTPayload = AppUserJWTPayload

    static var jwkIdentifier: JWKIdentifier = "refresh"

    let expirationTimeInterval: TimeInterval
}
