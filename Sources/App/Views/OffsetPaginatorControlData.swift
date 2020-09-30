import Fluent
import HypertextLiteral
import Vapor

struct OffsetPaginatorControlData: Codable {
    private struct _URLQueryContainer: URLQueryContainer {
        var url: URI

        func decode<D>(_ decodable: D.Type, using decoder: URLQueryDecoder) throws -> D
            where D: Decodable
        {
            return try decoder.decode(D.self, from: self.url)
        }

        mutating func encode<E>(_ encodable: E, using encoder: URLQueryEncoder) throws
            where E: Encodable
        {
            try encoder.encode(encodable, to: &self.url)
        }
    }

    struct Control: Codable {
        let url: String
        let page: Int
    }

    let current: Control
    let previous: Control?
    let next: Control?
    let first: Control
    let last: Control?
    let left: Bool
    let right: Bool
    let middle: [Control]

    init(url: URI, totalResults: Int) throws {
        var queryContainer = _URLQueryContainer(url: url)
        let pageRequest = try queryContainer.decode(PageRequest.self)
        let currentPage = pageRequest.page

        func link(page: Int) throws -> String {
            try queryContainer.encode(["page": page])
            return queryContainer.url.description
        }

        func control(page: Int) throws -> Control {
            Control(url: try link(page: page), page: page)
        }

        let totalPages = max(1, Int(ceil(Double(totalResults) / Double(pageRequest.per))))

        current = Control(url: url.description, page: currentPage)
        previous = current.page > 1 ? try control(page: min(currentPage - 1, totalPages)) : nil
        next = currentPage < totalPages ? try control(page: currentPage + 1) : nil
        first = try control(page: 1)

        last = totalPages == 1 ? nil : try control(page: totalPages)

        let showDots = totalPages > 9
        left = showDots && currentPage >= 5
        right = showDots && currentPage <= totalPages - 5
        middle = totalPages <= 2 ? [] : try OffsetPaginatorControlData
            .bounds(
                left: left,
                right: right,
                current: currentPage,
                total: totalPages
            ).map(control)
    }

    private static func bounds(
        left: Bool,
        right: Bool,
        current: Int,
        total: Int
    ) -> ClosedRange<Int> {
        switch (left, right) {
        case (false, false): return min(total, 2)...total - 1
        case (false, true): return 2...min(7, total)
        case (true, true): return current - 2...current + 2
        case (true, false): return max(1, total - 6)...total - 1
        }
    }
}

extension OffsetPaginatorControlData: HypertextLiteralConvertible {
    private var previousSection: HTML {
        let listItemAttributes: Attributes = [
            "class": ["page-item", previous == nil ? "disabled" as String : nil].compactMap { $0 }
        ]

        let anchorAttributes: Attributes = [
            "href": previous?.url,
            "class": "page-link",
            "rel": "prev",
            "aria-label": "Previous"
        ]

        return """
        <li \(listItemAttributes)>
            <a \(anchorAttributes)>
                <span aria-hidden="true">&laquo;</span>
                <span class="sr-only">Previous</span>
            </a>
        </li>
        """
    }

    private var nextSection: HTML {
        let listItemAttributes: Attributes = [
            "class": ["page-item", next == nil ? "disabled" as String : nil].compactMap { $0 }
        ]

        let anchorAttributes: Attributes = [
            "href": next?.url as Any,
            "class": "page-link",
            "rel": "next",
            "aria-label": "Next"
        ]

        return """
        <li \(listItemAttributes)>
            <a \(anchorAttributes)>
                <span aria-hidden="true">&raquo;</span>
                <span class="sr-only">Next</span>
            </a>
        </li>
        """
    }

    private func pageItem(
        active: Bool = false,
        disabled: Bool = false,
        text: String,
        url: String = "#"
    ) -> HTML {
        let attributes: Attributes = [
            "class": [
                "page-item",
                active ? "active" as String : nil,
                disabled ? "disabled" as String : nil
            ].compactMap { $0 }
        ]
        return """
        <li \(attributes)>
            <a href="\(url)" class="page-link">\(text)</a>
        </li>
        """
    }

    private func pageItem(control: Control) -> HTML {
        pageItem(
            active: current.page == control.page,
            text: control.page.description,
            url: control.url
        )
    }

    var html: HTML {
        """
        <nav class="paginator">
            <ul class="pagination justify-content-center table-responsive">
                \(previousSection)
                \(pageItem(control: first))
                \(left ? pageItem(disabled: true, text: "...") : "")
                \(middle.map(pageItem))
                \(right ? pageItem(disabled: true, text: "...") : "")
                \(last.map(pageItem) ?? "")
                \(nextSection)
            </ul>
        </nav>
        """
    }
}
