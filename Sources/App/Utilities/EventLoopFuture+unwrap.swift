import Vapor

extension EventLoopFuture where Value: OptionalType {
    func unwrap() -> EventLoopFuture<Value.WrappedType> {
        unwrap(or: HumacError.entityNotFound(ofType: Value.WrappedType.self))
    }
}
