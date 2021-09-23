import Vapor

public struct DataWrapper<T> {
    enum CodingKeys: String, CodingKey {
        case data
    }

    let data: T?
    let status: HTTPResponseStatus
}

extension DataWrapper {
    public init(data: T) {
        self.data = data
        self.status = .ok
    }
}

extension DataWrapper: Encodable where T: Encodable {}
extension DataWrapper: ResponseEncodable where T: Encodable {
    public func encodeResponse(for request: Request) -> EventLoopFuture<Response> {
        do {
            let response = Response()
            try response.content.encode(self, as: .json)
            response.status = status
            return request.eventLoop.future(response)
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }
    }
}

extension DataWrapper {
    public func withStatus(_ status: HTTPResponseStatus) -> Self {
        Self(data: data, status: status)
    }
}
