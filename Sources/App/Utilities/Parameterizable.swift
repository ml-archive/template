import FluentKit
import Vapor

protocol Parameterizable {
    associatedtype ParameterValue: LosslessStringConvertible
    static var parameter: String { get }
}

extension Model where Self: Parameterizable {
    typealias ParameterValue = IDValue
}

extension Parameterizable {
    static var pathComponent: PathComponent { .parameter(parameter) }

    static func requireParameter(on request: Request) throws -> ParameterValue {
        guard let parameterValue: ParameterValue = request.parameters.get(parameter) else {
            throw AppError.parameterNotFound(parameter, ofType: ParameterValue.self)
        }
        return parameterValue
    }
}
