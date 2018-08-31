import AdminPanel
import JWTKeychain
import Reset

internal struct Endpoints {
    enum API {}
    enum Backend {}
}

// MARK: API

extension Endpoints.API {
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

extension Endpoints.Backend {
    private static let backend = "/admin"
    // FIXME: backend endpoints here
}

// MARK: JWTKeychain

internal extension JWTKeychainEndpoints {
    internal static var apiPrefixed: JWTKeychainEndpoints {
        return .init(
            login: Endpoints.API.Users.login,
            me: Endpoints.API.Users.me,
            token: Endpoints.API.Users.token,
            update: Endpoints.API.Users.update
        )
    }
}

// MARK: Reset

internal extension ResetEndpoints {
    internal static var stark: ResetEndpoints {
        return .init(
            resetPasswordRequest: Endpoints.API.Users.ResetPassword.request,
            renderResetPassword: Endpoints.API.Users.ResetPassword.renderReset,
            resetPassword: Endpoints.API.Users.ResetPassword.reset
        )
    }
}
