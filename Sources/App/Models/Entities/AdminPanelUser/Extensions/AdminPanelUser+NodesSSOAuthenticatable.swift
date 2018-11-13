import AdminPanel
import FluentMySQL
import NodesSSO
import Sugar
import Vapor

extension AdminPanelUser: NodesSSOAuthenticatable {
    public static func authenticated(
        _ user: AuthenticatedUser,
        req: Request
    ) -> Future<Response> {
        return AdminPanelUser
            .query(on: req)
            .filter(\.email == user.email)
            .first()
            .flatMap(to: AdminPanelUser.self) { lookedupUser in
                guard let existingUser = lookedupUser else {
                    let randomPassword = String.randomAlphaNumericString(10)
                    return try AdminPanelUser(
                        email: user.email,
                        name: user.name,
                        avatarURL: user.imageURL,
                        role: AdminPanelUser.Role.superAdmin,
                        password: try AdminPanelUser.hashPassword(randomPassword)
                        ).save(on: req)
                }

                return req.future(existingUser)
            }
            .try { user in
                try req.authenticate(user)
            }
            .flatMap(to: Response.self) { user in
                try req
                    .redirect(to: AdminPanelEndpoints.default.dashboard)
                    .flash(.success, "Logged in as \(user.email)")
                    .encode(for: req)
        }
    }
}
