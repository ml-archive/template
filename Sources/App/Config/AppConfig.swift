import Fluent
import Sugar
import Vapor

internal struct AppConfig: Service {
    struct ResetPasswordEmail {
        let fromEmail = "no-reply@like.st"
        let subject = "Reset Password"
    }

    struct SetPasswordEmail {
        let fromEmail = "no-reply@like.st"
        let subject = "Set Password"
    }

    struct NewUserRequestEmail {
        let fromEmail = "no-reply@like.st"
        let toEmail = "test+user@nodes.dk"
        let subject = "New User Request"
    }

    let resetPasswordEmail = ResetPasswordEmail()
    let setPasswordEmail = SetPasswordEmail()
    let newUserRequestEmail = NewUserRequestEmail()
    let newAppUserSetPasswordSigner: ExpireableJWTSigner

    init() {
        newAppUserSetPasswordSigner = ExpireableJWTSigner(
            expirationPeriod: 2592000, // 30 days
            signer: .hs256(
                key: env(
                    EnvironmentKey.Reset.setPasswordSignerKey, "secret-reset"
                ).convertToData())
            )
    }
}
