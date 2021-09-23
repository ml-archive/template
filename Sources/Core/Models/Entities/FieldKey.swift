import FluentKit

extension FieldKey {
    // AppUser
    static let email: FieldKey = "email"
    static let hashedPassword: FieldKey = "hashed_password"
    static let name: FieldKey = "name"
    static let shouldResetPassword: FieldKey = "should_reset_password"

    // Timestamps
    static let createdAt: FieldKey = "created_at"
    static let updatedAt: FieldKey = "updated_at"
}
