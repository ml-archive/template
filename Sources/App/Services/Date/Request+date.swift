import Vapor

extension Request {
    struct Date {
        let request: Request

        func current() -> Foundation.Date { request.application.date.current() }
    }

    var date: Date { .init(request: self) }
}
