import Fluent
import Sugar
import Vapor

internal struct ProjectConfig: Service {
    let name: String
    let url: String

    struct ResetPasswordEmail {
        let fromEmail: String// = "no-reply@like.st"
        let subject: String// = "Reset Password"
    }

    struct SetPasswordEmail {
        let fromEmail: String// = "no-reply@like.st"
        let subject: String// = "Set Password"
    }

    struct NewUserRequestEmail {
        let fromEmail: String// = "no-reply@like.st"
        let toEmail: String// = "test+user@nodes.dk"
        let subject: String// = "New User Request"
    }

    let resetPasswordEmail: ResetPasswordEmail
    let setPasswordEmail: SetPasswordEmail
    let newUserRequestEmail: NewUserRequestEmail
    let newAppUserSetPasswordSigner: ExpireableJWTSigner
}
