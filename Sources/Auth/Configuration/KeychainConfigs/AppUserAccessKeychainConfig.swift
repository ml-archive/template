import Foundation
import JWT
import Keychain

public struct AppUserAccessKeychainConfig: KeychainConfig {
    public typealias JWTPayload = AppUserJWTPayload

    public static var jwkIdentifier: JWKIdentifier = "access"

    public let expirationTimeInterval: TimeInterval

    public init(expirationTimeInterval: TimeInterval) {
        self.expirationTimeInterval = expirationTimeInterval
    }
}
