import FluentMySQL
import Vapor

final class AppUser: Codable {
    var id: Int?
    var email: String
    var name: String

    var password: String
    var passwordChangeCount: Int

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    init(
        id: Int? = nil,
        email: String,
        name: String,
        password: String,
        passwordChangeCount: Int = 0
    ) throws {
        self.id = id
        self.email = email
        self.name = name
        self.password = try AppUser.hashPassword(password)
        self.passwordChangeCount = passwordChangeCount
    }
}

extension AppUser: MySQLModel {
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    static var deletedAtKey: TimestampKey? = \.deletedAt
}

extension AppUser: Content {}
extension AppUser: Migration {}
extension AppUser: Parameter {}
