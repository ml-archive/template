import FluentKit
import Vapor

public protocol Parameterizable {
    associatedtype ParameterValue
    static var parameter: String { get }
    static func getParameter(on request: Request) -> ParameterValue?
}

extension Model where Self: Parameterizable {
    public typealias ParameterValue = IDValue
}

public extension Parameterizable {
    static var pathComponent: PathComponent { .parameter(parameter) }

    static func requireParameter(on request: Request) throws -> ParameterValue {
        guard let parameterValue = getParameter(on: request) else {
            throw CoreError.parameterNotFound(parameter, ofType: ParameterValue.self)
        }
        return parameterValue
    }
}

public extension Parameterizable where ParameterValue: LosslessStringConvertible {
    static func getParameter(on request: Request) -> ParameterValue? {
        request.parameters.get(parameter)
    }
}
