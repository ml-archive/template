import Fluent
import Vapor

extension URLQueryContainer {
    public var searchTerm: String? {
        try? get(String.self, at: "searchterm")
    }

    public var pageRequest: PageRequest {
        (try? decode(PageRequest.self)) ?? PageRequest(page: 1, per: 10)
    }
}
