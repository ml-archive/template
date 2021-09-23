import Vapor

public extension Request {
    struct Date {
        let request: Request

        public func current() -> Foundation.Date { request.application.date.current() }
    }

    var date: Date { .init(request: self) }
}
