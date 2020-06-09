import Vapor

struct RefreshTokenResponse: Content {
    let refreshToken: String

    init(_ refreshToken: String) {
        self.refreshToken = refreshToken
    }
}
