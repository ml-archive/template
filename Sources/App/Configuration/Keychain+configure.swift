import Auth
import Keychain
import Vapor

extension Application.Keychain {
    func configure(_ application: Application) {
        application.keychain.configure(
            signer: .hs256(key: Environment.AppUser.AccessToken.signerKey),
            config: AppUserAccessKeychainConfig(
                expirationTimeInterval: Environment.AppUser.AccessToken.expiration
            )
        )
        application.keychain.configure(
            signer: .hs256(key: Environment.AppUser.RefreshToken.signerKey),
            config: AppUserRefreshKeychainConfig(
                expirationTimeInterval: Environment.AppUser.RefreshToken.expiration
            )
        )
        application.keychain.configure(
            signer: .hs256(key: Environment.AppUser.ResetToken.signerKey),
            config: AppUserResetKeychainConfig(
                emailSender: Environment.AppUser.Reset.emailSender,
                expirationTimeInterval: Environment.AppUser.ResetToken.expiration,
                resetBaseURL: Environment.AppUser.Reset.baseURL,
                resetEmailSubject: Environment.AppUser.Reset.emailSubject,
                welcomeEmailSubject: Environment.AppUser.Welcome.emailSubject
            )
        )
    }
}
