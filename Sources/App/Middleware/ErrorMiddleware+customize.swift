import Vapor

extension ErrorMiddleware {
    struct ErrorResponse: Encodable {
        struct ErrorPayload: Encodable {
            struct ValidationError: Encodable {
                let field: String
                let message: String
            }
            let message: String
            let validationErrors: [ValidationError]?
        }
        let error: ErrorPayload
    }

    public static func customize(environment: Environment) -> ErrorMiddleware {
        .init { request, error in
            let status: HTTPResponseStatus
            let message: String
            let headers: HTTPHeaders
            let validationErrors: [ErrorResponse.ErrorPayload.ValidationError]?

            switch error {
            case let validationsError as ValidationsError:
                message = validationsError.reason
                status = .unprocessableEntity // don't use `badRequest` that Vapor wants us to use
                headers = validationsError.headers
                validationErrors = validationsError.failures.compactMap { failure in
                    guard let message = failure.failureDescription else {
                        return nil
                    }
                    return .init(field: failure.key.stringValue, message: message)
                }
            case let abort as AbortError:
                message = abort.reason
                status = abort.status
                headers = abort.headers
                validationErrors = nil
            default:
                message = environment.isRelease
                    ? "Something went wrong."
                    : String(describing: error)
                status = .internalServerError
                headers = [:]
                validationErrors = nil
            }

            request.logger.report(error: error)

            let response = Response(status: status, headers: headers)
            let errorResponse = ErrorResponse(error: .init(message: message, validationErrors: validationErrors))
            do {
                try response.content.encode(errorResponse, as: .json)
            } catch {
                response.body = .init(string: "Oops: \(error)")
                response.headers.replaceOrAdd(name: .contentType, value: "text/plain; charset=utf-8")
            }
            return response
        }
    }
}
