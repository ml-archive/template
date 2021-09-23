import Core
import JWT
import Keychain
import Mailgun
import Vapor

public struct AppUserResetKeychainConfig: KeychainConfig {
    public typealias JWTPayload = AppUserJWTPayload

    public static let jwkIdentifier: JWKIdentifier = "reset"

    public let emailSender: String
    public let expirationTimeInterval: TimeInterval
    public let resetBaseURL: String
    public let resetEmailSubject: String
    public let welcomeEmailSubject: String

    public init(
        emailSender: String,
        expirationTimeInterval: TimeInterval,
        resetBaseURL: String,
        resetEmailSubject: String,
        welcomeEmailSubject: String
    ) {
        self.emailSender = emailSender
        self.expirationTimeInterval = expirationTimeInterval
        self.resetBaseURL = resetBaseURL
        self.resetEmailSubject = resetEmailSubject
        self.welcomeEmailSubject = welcomeEmailSubject
    }
}

extension AppUserResetKeychainConfig {
    public func sendPasswordResetEmail(
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

    public func sendWelcomeEmail(
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
