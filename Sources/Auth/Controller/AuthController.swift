import Core
import Fluent
import User
import Vapor

struct AuthController {
    func logIn(request: Request) -> EventLoopFuture<DataWrapper<AppUserLoginResponse>> {
        AppUserLoginRequest
            .logIn(
                on: request,
                errorOnWrongPassword: CoreError.incorrectCredentials,
                currentDate: request.date.current()
            )
            .flatMapThrowing { try $0.map(AppUserMeResponse.init) }
            .map(DataWrapper.init)
    }

    func refreshToken(request: Request) throws -> DataWrapper<RefreshTokenResponse> {
        try .init(data: .init(AppUserRefreshKeychainConfig.makeToken(on: request)))
    }
}

extension AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.post("login", use: logIn)

        routes
            .grouped(AppUserRefreshKeychainConfig.authenticator)
            .post("refresh-token", use: refreshToken)
    }
}
