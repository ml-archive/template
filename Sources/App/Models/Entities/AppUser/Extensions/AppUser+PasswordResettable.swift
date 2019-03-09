import Leaf
import Mailgun
import Reset
import Sugar
import Vapor

extension AppUser: PasswordResettable {
    typealias Context = ResetPasswordContext

    struct RequestReset: HasReadableUsername, SelfCreatable {
        static let readableUsernameKey = \RequestReset.username
        public let username: String
    }

    struct ResetPassword: HasReadablePassword, SelfCreatable {
        static let readablePasswordKey = \ResetPassword.password
        public let password: String
    }

    struct ResetPasswordEmail: Codable {
        let url: String
        let expire: Int
    }

    func sendPasswordReset(
        url: String,
        token: String,
        expirationPeriod: TimeInterval,
        context: ResetPasswordContext,
        on req: Request
    ) throws -> Future<Void> {
        let mailgun = try req.make(Mailgun.self)
        let projectConfig = try req.make(ProjectConfig.self)
        let emailData = ResetPasswordEmail(url: url, expire: Int(expirationPeriod / 60))

        return try req
            .view()
            .render(ViewPath.Reset.resetPasswordEmail, emailData)
            .map { view in
                String(bytes: view.data, encoding: .utf8) ?? ""
            }
            .map { html in
                Mailgun.Message(
                    from: projectConfig.resetPasswordEmail.fromEmail,
                    to: self.email,
                    subject: projectConfig.resetPasswordEmail.subject,
                    text: "Please turn on html to view this email.",
                    html: html
                )
            }
            .flatMap { message in
                try mailgun.send(message, on: req)
            }
            .transform(to: ())
    }
}
