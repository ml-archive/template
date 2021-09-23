import Vapor

extension EventLoopFuture where Value: OptionalType {
    public func unwrap() -> EventLoopFuture<Value.WrappedType> {
        unwrap(or: CoreError.entityNotFound(ofType: Value.WrappedType.self))
    }
}
