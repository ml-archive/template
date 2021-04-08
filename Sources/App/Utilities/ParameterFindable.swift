import FluentKit
import Submissions
import Vapor

protocol ParameterFindable: Parameterizable {
    static func find(parameterValue: ParameterValue, on request: Request) -> EventLoopFuture<Self?>
}

extension ParameterFindable {
    static func find(on request: Request) -> EventLoopFuture<Self?> {
        request.eventLoop
            .submit { try requireParameter(on: request) }
            .flatMap { parameterValue in
                find(parameterValue: parameterValue, on: request)
            }
    }
}

extension UpdateRequest where Model: ParameterFindable {
    static func find(on request: Request) -> EventLoopFuture<Model> {
        Model.find(on: request).unwrap()
    }
}
