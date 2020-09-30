import JWT
import HypertextLiteral
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

    private func resetLink(forToken token: String) -> String {
        "\(resetBaseURL)/\(token)"
    }

    func sendPasswordResetEmail(
        for user: AppUser,
        token: String,
        on request: Request
    ) -> EventLoopFuture<Void> {
        sendEmail(
            to: user,
            html: request.html.passwordResetEmail(
                name: user.name,
                resetLink: resetLink(forToken: token)
            ),
            emailSubject: resetEmailSubject,
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
                html: request.html.welcomeEmail(
                    name: user.name,
                    resetLink: resetLink(
                        forToken: try makeToken(for: user, on: request, currentDate: currentDate)
                    )
                ),
                emailSubject: self.welcomeEmailSubject,
                on: request
            )
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }
    }

    private func sendEmail(
        to user: AppUser,
        html: HTML,
        emailSubject: String,
        on request: Request
    ) -> EventLoopFuture<Void> {
        request
            .mailgun()
            .send(.init(
                from: emailSender,
                to: user.email,
                subject: emailSubject,
                text: "",
                html: html.description
            ))
            .transform(to: ())
    }
}
