import Foundation
import JWT
import Keychain

public struct AppUserRefreshKeychainConfig: KeychainConfig {
    public typealias JWTPayload = AppUserJWTPayload

    public static var jwkIdentifier: JWKIdentifier = "refresh"

    public let expirationTimeInterval: TimeInterval

    public init(expirationTimeInterval: TimeInterval) {
        self.expirationTimeInterval = expirationTimeInterval
    }
}
