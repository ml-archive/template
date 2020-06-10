import Vapor

enum AppError: Error {
    case entityNotFound(ofType: Any.Type, withID: String)
    case incorrectCredentials
    case parameterNotFound(String, ofType: Any.Type)
    case passwordsDoNotMatch
    case shouldResetPassword
    case wrongEndpoint(use: String)
}

extension AppError: AbortError {
    var reason: String {
        switch self {
        case let .entityNotFound(entityType, id):
            return "Entity of type \(entityType) with id \(id) not found."
        case .incorrectCredentials:
            return "Incorrect credentials"
        case let .parameterNotFound(parameter, ofType: parameterType):
            return "Path parameter \(parameter) of type \(parameterType) not found"
        case .passwordsDoNotMatch:
            return "Passwords do not match"
        case .shouldResetPassword:
            return "Password needs to be reset"
        case let .wrongEndpoint(use: url):
            return "Use \(url) in stead"
        }
    }

    var status: HTTPResponseStatus {
        switch self {
        case .entityNotFound:
            return .notFound
        case .incorrectCredentials:
            return .unauthorized
        case .parameterNotFound:
            return .badRequest
        case .passwordsDoNotMatch:
            return .unprocessableEntity
        case .shouldResetPassword:
            return .unauthorized
        case .wrongEndpoint:
            return .forbidden
        }
    }
}
