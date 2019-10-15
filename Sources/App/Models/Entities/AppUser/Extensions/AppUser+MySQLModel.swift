import FluentMySQL

extension AppUser: MySQLModel {
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    static var deletedAtKey: TimestampKey? = \.deletedAt
}
