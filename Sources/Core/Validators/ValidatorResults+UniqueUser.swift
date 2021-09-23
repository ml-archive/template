import Vapor

public extension ValidatorResults {
    struct UniqueUser: ValidatorResult {
        let isUniqueUser: Bool
        public var isFailure: Bool { !isUniqueUser }
        public var successDescription: String? { "user does not exist" }
        public var failureDescription: String? { "user already exists" }

        public init(isUniqueUser: Bool) {
            self.isUniqueUser = isUniqueUser
        }
    }
}
