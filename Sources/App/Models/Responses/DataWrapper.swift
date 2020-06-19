import Foundation
import Vapor

struct DataWrapper<T> {
    let data: T?
}

extension DataWrapper: Decodable where T: Decodable {}
extension DataWrapper: Encodable where T: Encodable {}
extension DataWrapper: Content where T: Content {}
extension DataWrapper: RequestDecodable where T: Content {}
extension DataWrapper: ResponseEncodable where T: Content {}

extension DataWrapper: Equatable where T: Equatable {}
