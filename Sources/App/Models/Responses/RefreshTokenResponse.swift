import Vapor

struct RefreshTokenResponse: Encodable {
    let refreshToken: String

    init(_ refreshToken: String) {
        self.refreshToken = refreshToken
    }
}
