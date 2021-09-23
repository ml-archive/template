import Mailgun
import Vapor


extension Environment {
    struct AppUser {

        // MARK: App User Access Token

        struct AccessToken {
            static var signerKey: Data {
                assertGet("APP_USER_ACCESS_TOKEN_SIGNER_KEY").data(using: .utf8)!
            }

            static var expiration: TimeInterval {
                TimeInterval(assertGet("APP_USER_ACCESS_TOKEN_EXPIRATION")) ?? 3600
            }
        }

        // MARK: App User Refresh Token

        struct RefreshToken {
            static var signerKey: Data {
                assertGet("APP_USER_REFRESH_TOKEN_SIGNER_KEY").data(using: .utf8)!
            }

            static var expiration: TimeInterval {
                TimeInterval(assertGet("APP_USER_REFRESH_TOKEN_EXPIRATION")) ?? 3600 * 24 * 365
            }
        }

        // MARK: App User (Re)set Token

        struct ResetToken {
            static var signerKey: Data {
                assertGet("APP_USER_RESET_TOKEN_SIGNER_KEY").data(using: .utf8)!
            }

            static var expiration: TimeInterval {
                TimeInterval(assertGet("APP_USER_RESET_TOKEN_EXPIRATION")) ?? 3600
            }
        }

        // MARK: App User (Re)set Email

        struct Reset {
            static var emailSender: String { assertGet("APP_USER_RESET_EMAIL_SENDER") }
            static var emailSubject: String { assertGet("APP_USER_RESET_EMAIL_SUBJECT") }
            static var baseURL: String { assertGet("APP_USER_RESET_BASE_URL") }
        }

        // MARK: App User Welcome Email
        
        struct Welcome {
            static var emailSubject: String { assertGet("APP_USER_WELCOME_EMAIL_SUBJECT") }
        }
    }

    // MARK: Bugsnag

    struct Bugsnag {
        static var apiKey: String { assertGet("BUGSNAG_API_KEY") }
    }

    // MARK: Mailgun

    struct Mailgun {
        static var apiKey: String { assertGet("MAILGUN_API_KEY") }
        static var defaultDomain: String { assertGet("MAILGUN_DEFAULT_DOMAIN") }
        static var region: MailgunRegion { MailgunRegion(rawValue: assertGet("MAILGUN_REGION")) ?? .us }
    }

    // MARK: PostgreSQL

    struct PostgreSQL {
        static var url: String { assertGet("POSTGRESQL_URL") }
    }
}
