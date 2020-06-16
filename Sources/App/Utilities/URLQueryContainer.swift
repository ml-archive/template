import Fluent
import Vapor

extension URLQueryContainer {
    var searchTerm: String? {
        try? get(String.self, at: "searchterm")
    }

    var pageRequest: PageRequest {
        (try? decode(PageRequest.self)) ?? PageRequest(page: 1, per: 10)
    }
}
