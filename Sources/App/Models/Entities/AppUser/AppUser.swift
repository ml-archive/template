import Foundation

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
