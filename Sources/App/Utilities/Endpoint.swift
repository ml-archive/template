import AdminPanel
import JWTKeychain
import Reset

internal struct Endpoint {
    enum API {}
    enum Backend {}
}

// MARK: API

extension Endpoint.API {
    private static let api = "/api"

    enum Users {
        private static let users = api + "/users"
        static let login = users + "/login"
        static let me = users + "/me"
        static let token = users + "/token"
        static let update = users + "/me"
        static let request = users + "/request"

        enum ResetPassword {
            private static let resetPassword = users + "/reset-password"
            static let request = resetPassword + "/request"
            static let renderReset = resetPassword
            static let reset = resetPassword
        }
    }
}

// MARK: Backend

extension Endpoint.Backend {
    private static let backend = "/admin"
    // FIXME: backend endpoints here
}

// MARK: JWTKeychain

internal extension JWTKeychainEndpoints {
    internal static var apiPrefixed: JWTKeychainEndpoints {
        return .init(
            login: Endpoint.API.Users.login,
            me: Endpoint.API.Users.me,
            token: Endpoint.API.Users.token,
            update: Endpoint.API.Users.update
        )
    }
}

// MARK: Reset

internal extension ResetEndpoints {
    internal static var stark: ResetEndpoints {
        return .init(
            resetPasswordRequest: Endpoint.API.Users.ResetPassword.request,
            renderResetPassword: Endpoint.API.Users.ResetPassword.renderReset,
            resetPassword: Endpoint.API.Users.ResetPassword.reset
        )
    }
}
