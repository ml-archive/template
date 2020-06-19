import Vapor

extension ValidatorResults {
    struct UniqueUser: ValidatorResult {
        let isUniqueUser: Bool
        var isFailure: Bool { !isUniqueUser }
        var successDescription: String? { "user does not exist" }
        var failureDescription: String? { "user already exists" }
    }
}
