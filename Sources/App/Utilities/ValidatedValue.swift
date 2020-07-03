import Vapor

struct ValidatedValue<T> where T: Decodable & CustomStringConvertible {
    let value: String?
    let failureDescriptions: [String]
    let isValid: Bool?

    init(
        value: String? = nil,
        failureDescriptions: [String] = [],
        isValid: Bool? = nil
    ) {
        self.value = value
        self.failureDescriptions = failureDescriptions
        self.isValid = isValid
    }
}

extension ValidationsError {
    func validatedValue<T>(for key: String, from request: Request) -> ValidatedValue<T> {
        let failureDescriptions = failures
            .filter { $0.key.stringValue == key }
            .compactMap(\.failureDescription)

        return .init(
            value: (try? request.content.get(T.self, at: key))?.description,
            failureDescriptions: failureDescriptions,
            isValid: failureDescriptions.isEmpty
        )
    }
}

extension Request {
    func validatedValue<T>(for key: String, error: Error) -> ValidatedValue<T> {
        let failureDescriptions: [String]
        let isValid: Bool?
        if let error = error as? ValidationsError {
            failureDescriptions = error.failures
                .filter { $0.key.stringValue == key }
                .compactMap(\.failureDescription)
            isValid = failureDescriptions.isEmpty
        } else {
            failureDescriptions = []
            isValid = nil // something's wrong but we don't know if it's this value
        }

        return .init(
            value: (try? content.get(T.self, at: key))?.description,
            failureDescriptions: failureDescriptions,
            isValid: isValid
        )
    }
}
