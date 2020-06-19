import Fluent
import Vapor

struct NodesPage<T: Codable>: Codable {
    let data: [T]
    let metadata: NodesPageMetadata
}

extension NodesPage {
    init(page: Page<T>) {
        self.data = page.items
        self.metadata = .init(page.metadata)
    }
}

extension NodesPage: Content, RequestDecodable, ResponseEncodable where T: Content {}

/// This is a copy of PageMetadata. Included here to enable control over initialization (for OpenAPI examples).
struct NodesPageMetadata: Codable {
    /// Current page number. Starts at `1`.
    public let page: Int

    /// Max items per page.
    public let per: Int

    /// Total number of items available.
    public let total: Int
}

extension NodesPageMetadata {
    init(_ pageMetaData: PageMetadata) {
        self.page = pageMetaData.page
        self.per = pageMetaData.per
        self.total = pageMetaData.total
    }
}
