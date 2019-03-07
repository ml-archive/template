import Authentication

extension AppUser: PasswordAuthenticatable {
    static let usernameKey: WritableKeyPath<AppUser, String> = \.email
    static let passwordKey: WritableKeyPath<AppUser, String> = \.password
}
