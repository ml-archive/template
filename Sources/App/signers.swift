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
    app.keychain.configure(
        signer: .hs256(key: Environment.appUserResetTokenSignerKey),
        config: AppUserResetKeychainConfig(
            emailSender: Environment.appUserResetEmailSender,
            expirationTimeInterval: Environment.appUserResetTokenExpiration,
            resetBaseURL: Environment.appUserResetBaseURL,
            resetEmailSubject: Environment.appUserResetEmailSubject,
            welcomeEmailSubject: Environment.appUserWelcomeEmailSubject
        )
    )
}
