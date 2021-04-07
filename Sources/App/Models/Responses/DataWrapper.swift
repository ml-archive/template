import Vapor

struct DataWrapper<T> {
    let data: T?
}

extension DataWrapper: Encodable where T: Encodable {}
extension DataWrapper: ResponseEncodable where T: Encodable {
    func encodeResponse(for request: Request) -> EventLoopFuture<Response> {
        do {
            let response = Response()
            try response.content.encode(self, as: .json)
            return request.eventLoop.future(response)
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }
    }
}
