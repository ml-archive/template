import HypertextLiteral
import Vapor

struct AppUserViewController {
    func renderLogin(request: Request) -> HTML {
        request.html.login()
    }

    func logIn(request: Request) throws -> EventLoopFuture<Response> {
        request.eventLoop
            .future(result: .init { try AppUserViewLoginRequest.validate(content: request) })
            .flatMapThrowing { try request.content.decode(AppUserViewLoginRequest.self) }
            .flatMap { loginRequest in
                request.repositories.appUser
                    .findByEmail(loginRequest.email)
                    .unwrap(or: AppError.incorrectCredentials)
                    .flatMap { user in
                        request.password.async
                            .verify(loginRequest.password, created: user.hashedPassword)
                            .flatMapThrowing { isValid in
                                guard isValid else { throw AppError.incorrectCredentials }
                            }.transform(to: user)
                    }
                    .map(request.auth.login)
                    .map { request.redirect(to: "/dashboard") }
            }
            .flatMapError { error in
                request.html.login(
                    email: request.validatedValue(
                        for: AppUserViewLoginRequest.CodingKeys.email.rawValue,
                        error: error
                    ),
                    password: request.validatedValue(
                        for: AppUserViewLoginRequest.CodingKeys.password.rawValue,
                        error: error
                    ),
                    alerts: .init(error)
                ).encodeResponse(for: request)
            }
    }
}

extension AppUserViewController: RouteCollection {
    func boot(routes: RoutesBuilder) {
        routes.get("login", use: renderLogin)
        routes.post("login", use: logIn)
    }
}
