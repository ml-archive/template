import Bugsnag
import FluentKit
import Vapor

final class AppUser: Authenticatable, Model {
    static let schema = "app_users"

    @ID
    var id: UUID?

    @Field(key: .email)
    var email: String

    @Field(key: .hashedPassword)
    var hashedPassword: String

    @Timestamp(key: .createdAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: .updatedAt, on: .update)
    var updatedAt: Date?

    init() {}

    init(id: UUID? = nil, hashedPassword: String) {
        self.id = id
        self.hashedPassword = hashedPassword
    }
}

extension AppUser: BugsnagUser {
    var bugsnagID: CustomStringConvertible? { id }
}

extension AppUser: Parameterizable {
    static var parameter: String { "userID" }

    static func find(parameterValue: IDValue, on request: Request) -> EventLoopFuture<AppUser?> {
        request.repositories.appUser.find(parameterValue)
    }
}
