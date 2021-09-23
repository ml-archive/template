import FluentKit
import Foundation
import Vapor

public final class AppUser: Model {
    public static let schema = "app_users"

    @ID
    public var id: UUID?

    // Timestamps

    @Timestamp(key: .createdAt, on: .create)
    public var createdAt: Date?

    @Timestamp(key: .updatedAt, on: .update)
    public var updatedAt: Date?

    // Fields

    @Field(key: .name)
    public var name: String

    @Field(key: .email)
    public var email: String

    @Field(key: .hashedPassword)
    public var hashedPassword: String

    @Field(key: .shouldResetPassword)
    public var shouldResetPassword: Bool

    public init() {}

    public init(
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
