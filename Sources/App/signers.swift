import Vapor

func signers(_ app: Application) {
    app.keychain.configure(
        signer: .hs256(key: Environment.appUserAccessTokenSignerKey),
        config: AppUserAccessKeychainConfig(
            expirationTimeInterval: Environment.appUserAccessTokenExpiration
        )
    )
    app.keychain.configure(
        signer: .hs256(key: Environment.appUserRefreshTokenSignerKey),
        config: AppUserRefreshKeychainConfig(
            expirationTimeInterval: Environment.appUserRefreshTokenExpiration
        )
    )
}
