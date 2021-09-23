import Vapor

public extension ValidatorResults {
    struct StrongPassword {
        public let isStrongPassword: Bool
    }

    struct PasswordConfirmation {
        public let passwordsMatch: Bool
    }
}

extension ValidatorResults.StrongPassword: ValidatorResult {
    public var isFailure: Bool { !isStrongPassword }
    public var successDescription: String? { "is a strong password" }
    public var failureDescription: String? { "is a weak password" }
}

extension ValidatorResults.PasswordConfirmation: ValidatorResult {
    public var isFailure: Bool { !passwordsMatch }
    public var successDescription: String? { "matches stored password" }
    public var failureDescription: String? { "does not match stored password" }
}

public extension Validator where T == String {
    static var strongPassword: Validator<String> {
        .init { string in
            // TODO: add proper strong password validation
            ValidatorResults.StrongPassword(isStrongPassword: string.count >= 8)
        }
    }
}
