import Vapor

extension ValidatorResults {
    struct StrongPassword {
        let isStrongPassword: Bool
    }

    struct PasswordConfirmation {
        let passwordsMatch: Bool
    }
}

extension ValidatorResults.StrongPassword: ValidatorResult {
    var isFailure: Bool { !isStrongPassword }
    var successDescription: String? { "is a strong password" }
    var failureDescription: String? { "is a weak password" }
}

extension ValidatorResults.PasswordConfirmation: ValidatorResult {
    var isFailure: Bool { !passwordsMatch }
    var successDescription: String? { "matches stored password" }
    var failureDescription: String? { "does not match stored password" }
}

extension Validator where T == String {
    static var strongPassword: Validator<String> {
        .init { string in
            // TODO: add proper strong password validation
            ValidatorResults.StrongPassword(isStrongPassword: string.count >= 8)
        }
    }
}
