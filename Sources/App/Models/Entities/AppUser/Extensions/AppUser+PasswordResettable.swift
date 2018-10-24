import Fluent
import Foundation
import JWT
import Leaf
import Mailgun
import Reset
import Sugar
import Vapor

extension AppUser: PasswordResettable {
    typealias Context = ResetPasswordContext

    public struct RequestReset: RequestCreatable, Decodable, HasReadableUsername {
        static let readableUsernameKey = \RequestReset.username
        public let username: String
    }

    public struct ResetPassword: RequestCreatable, Decodable, HasReadablePassword {
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
        let appConfig = try req.make(AppConfig.self)
        let emailData = ResetPasswordEmail(url: url, expire: Int(expirationPeriod / 60))

        return try req
            .make(LeafRenderer.self)
            .render(View.Reset.resetPasswordEmail, emailData)
            .map(to: String.self) { view in
                String(bytes: view.data, encoding: .utf8) ?? ""
            }
            .map(to: Mailgun.Message.self) { html in
                Mailgun.Message(
                    from: appConfig.resetPasswordEmail.fromEmail,
                    to: self.email,
                    subject: appConfig.resetPasswordEmail.subject,
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
