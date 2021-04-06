import Bugsnag
import FluentKit
import Vapor

final class AppUser: Authenticatable, Model {
    static let schema = "app_users"

    @ID
    var id: UUID?

    @Field(key: .name)
    var name: String

    @Field(key: .email)
    var email: String

    @Field(key: .hashedPassword)
    var hashedPassword: String

    @Field(key: .shouldResetPassword)
    var shouldResetPassword: Bool

    @Timestamp(key: .createdAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: .updatedAt, on: .update)
    var updatedAt: Date?

    init() {}

    init(
        name: String,
        email: String,
        hashedPassword: String,
        shouldResetPassword: Bool = true
    ) {
        self.name = name
        self.email = email
        self.hashedPassword = hashedPassword
        self.shouldResetPassword = shouldResetPassword
    }
}

extension AppUser: BugsnagUser {
    var bugsnagID: CustomStringConvertible? { id }
}

extension AppUser: Parameterizable {
    static var parameter: String { "userID" }

    static func find(parameterValue id: IDValue, on request: Request) -> EventLoopFuture<AppUser?> {
        request.repositories.appUser.findAppUser(id)
    }
}
