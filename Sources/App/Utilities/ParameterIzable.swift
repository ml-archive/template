import Submissions
import Vapor

protocol Parameterizable {
    associatedtype ParameterValue: LosslessStringConvertible

    static var parameter: String { get }

    static func find(parameterValue: ParameterValue, on request: Request) -> EventLoopFuture<Self?>
}

extension Parameterizable {
    static var pathComponent: PathComponent { .parameter(parameter) }
}

extension Parameterizable {
    static func find(on request: Request) -> EventLoopFuture<Self> {
        guard let parameterValue = request.parameters.get(parameter, as: ParameterValue.self) else {
            return request.eventLoop.future(
                error: AppError.parameterNotFound(parameter, ofType: ParameterValue.self)
            )
        }
        return find(parameterValue: parameterValue, on: request)
            .unwrap(or: AppError.entityNotFound(
                ofType: Self.self,
                withID: parameterValue.description
            ))
    }
}

extension UpdateRequest where Model: Parameterizable {
    static func find(on request: Request) -> EventLoopFuture<Model> {
        Model.find(on: request)
    }
}
