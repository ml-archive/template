import Authentication
import Leaf
import Mailgun
import Reset
import Sugar

extension AppUser: PasswordAuthenticatable {
    static let usernameKey: WritableKeyPath<AppUser, String> = \.email
    static let passwordKey: WritableKeyPath<AppUser, String> = \.password
}

extension AppUser: PasswordResettable {
    typealias Context = ResetPasswordContext

    public struct RequestReset: SelfCreatable, Decodable, HasReadableUsername {
        static let readableUsernameKey = \RequestReset.username
        public let username: String
    }

    public struct ResetPassword: SelfCreatable, Decodable, HasReadablePassword {
        static let readablePasswordKey = \ResetPassword.password
        public let password: String
    }

    internal struct ResetPasswordEmail: Codable {
        let url: String
        let expire: Int
    }

    public func sendPasswordReset(
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
            .make(LeafRenderer.self)
            .render(ViewPath.Reset.resetPasswordEmail, emailData)
            .map(to: String.self) { view in
                String(bytes: view.data, encoding: .utf8) ?? ""
            }
            .map(to: Mailgun.Message.self) { html in
                Mailgun.Message(
                    from: projectConfig.resetPasswordEmail.fromEmail,
                    to: self.email,
                    subject: projectConfig.resetPasswordEmail.subject,
                    text: "Please turn on html to view this email.",
                    html: html
                )
            }
            .flatMap(to: Response.self) { message in
                try mailgun.send(message, on: req)
            }
            .transform(to: ())
    }

    // Multiple matches, so need to specify one here.
    public static func authenticate(
        using payload: AppUser.JWTPayload,
        on connection: DatabaseConnectable
        ) throws -> EventLoopFuture<AppUser?> {
        guard let id = ID(payload.sub.value) else {
            throw AuthenticationError.malformedPayload
        }

        return find(id, on: connection)
    }
}
