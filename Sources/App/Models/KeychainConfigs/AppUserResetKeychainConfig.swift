import JWT
import Keychain
import Mailgun
import Vapor

struct AppUserResetKeychainConfig: KeychainConfig {
    typealias JWTPayload = AppUserJWTPayload

    static let jwkIdentifier: JWKIdentifier = "reset"

    let emailSender: String
    let expirationTimeInterval: TimeInterval
    let resetBaseURL: String
    let resetEmailSubject: String
    let welcomeEmailSubject: String
}

extension AppUserResetKeychainConfig {
    func sendPasswordResetEmail(
        for user: AppUser,
        token: String,
        on request: Request
    ) -> EventLoopFuture<Void> {
        sendEmail(
            to: user,
            token: token,
            view: "resetPassword",
            emailSubject: self.resetEmailSubject,
            on: request
        )
    }

    func sendWelcomeEmail(
        for user: AppUser,
        on request: Request,
        currentDate: Date = Date()
    ) -> EventLoopFuture<Void> {
        do {
            return sendEmail(
                to: user,
                token: try makeToken(for: user, on: request, currentDate: currentDate),
                view: "welcome",
                emailSubject: self.welcomeEmailSubject,
                on: request
            )
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }
    }

    private func sendEmail(
        to user: AppUser,
        token: String,
        view: String,
        emailSubject: String,
        on request: Request
    ) -> EventLoopFuture<Void> {
        request
            .view
            .render("Emails/\(view)", [
                "name": user.name,
                "resetLink": "\(resetBaseURL)/\(token)"
            ]).flatMap { html in
                let message = MailgunMessage(
                    from: self.emailSender,
                    to: user.email,
                    subject: emailSubject,
                    text: "",
                    html: String(data: Data(html.data.readableBytesView), encoding: .utf8)
                )
                return request.mailgun().send(message).transform(to: ())
            }
    }
}
