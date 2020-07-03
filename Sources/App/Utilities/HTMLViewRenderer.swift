import Fluent
import HypertextLiteral
import Vapor

extension PageMetadata {
    static func nextAndPreviousLinks(
        currentPage: Int,
        totalPages: Int,
        url: URL
    ) throws -> (previous: String?, next: String?) {
        var previous: String? = nil
        var next: String? = nil

        if currentPage > 1 {
            let previousPage = (currentPage <= totalPages) ? currentPage - 1 : totalPages
            previous = try link(url: url, page: previousPage)
        }

        if currentPage < totalPages {
            next = try link(url: url, page: currentPage + 1)
        }

        return (previous, next)
    }

    static func link(url: URL, page: Int) throws -> String {
        guard
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            throw Abort(.internalServerError)
        }

        var queryItems = components.queryItems?.filter { $0.name != "page" } ?? []
        queryItems.append(URLQueryItem(name: "page", value: String(page)))
        components.queryItems = queryItems

        guard let url = components.url?.absoluteString else {
            throw Abort(.internalServerError)
        }

        return url
    }
}

public struct OffsetPaginatorControlData: Codable {
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

    init(metadata: PageMetadata, url: URL) throws {

        let totalPages = max(1, Int(ceil(Double(metadata.total) / Double(metadata.per))))

        let links = try PageMetadata.nextAndPreviousLinks(
            currentPage: metadata.page,
            totalPages: totalPages,
            url: url
        )

        current = Control(url: url.absoluteString, page: metadata.page)
        previous = links.previous.map { Control(url: $0, page: metadata.page - 1) }
        next = links.next.map { Control(url: $0, page: metadata.page + 1) }
        first = Control(url: try PageMetadata.link(url: url, page: 1), page: 1)

        let check = try PageMetadata.link(url: url, page: totalPages)
        last = first.url == check ? nil : Control(url: check, page: totalPages)

        let showDots = totalPages > 9
        left = showDots && metadata.page >= 5
        right = showDots && metadata.page <= totalPages - 5

        var middle: [Control]
        if totalPages > 2 {
            let bounds = OffsetPaginatorControlData.bounds(
                left: left,
                right: right,
                current: metadata.page,
                total: totalPages
            )

            let range: CountableClosedRange = bounds.lower...bounds.upper
            let middleLinks = try range.map { try PageMetadata.link(url: url, page: $0) }
            middle = zip(range, middleLinks).map { (page, url) in
                Control(url: url, page: page)
            }
        } else {
            middle = []
        }
        self.middle = middle
    }

    private static func bounds(
        left: Bool,
        right: Bool,
        current: Int,
        total: Int
    ) -> (lower: Int, upper: Int) {
        switch (left, right) {
        case (false, false): return (min(total, 2), total - 1)
        case (false, true): return (2, min(7, total))
        case (true, true): return (current - 2, current + 2)
        case (true, false): return (max(1, total - 6), total - 1)
        }
    }
}


extension OffsetPaginatorControlData: HypertextLiteralConvertible {
    private var previousSection: HTML {
        let listItemAttributes: [String: Any] = [
            "class": (previous == nil ? ["disabled"] : []) + ["page-item"]
        ]

        let anchorAttributes: [String: Any] = [
            "href": previous?.url,
            "class": "page-link",
            "rel": "prev",
            "aria-label": "Previous"
        ].removeNilValues()

        return """
        <li \(listItemAttributes)>
            <a \(anchorAttributes)>
                <span aria-hidden="true">&laquo;</span>
                <span class="sr-only">Previous</span>
            </a>
        </li>
        """
    }

    private func pageItem(isActive: Bool = false, text: String, url: String = "#") -> HTML {
        let attributes: [String: Any] = [
            "class": ["page-item", isActive ? "active" as Any : nil].compactMap { $0 }
        ]
        return """
        <li \(attributes)>
            <a href="\(url)" class="page-link">\(text)</a>
        </li>
        """
    }

    public var html: HTML {



        """
        <nav class="paginator">
            <ul class="pagination justify-content-center table-responsive">
                \(previousSection)
                \(pageItem())
                <li class="page-item #if(current.page == first.page) { active }"><a href="#(first.url)" class="page-link">#(first.page)</a></li>

                #if(left) {
                    <li class="disabled page-item"><a href="#" class="page-link">...</a></li>
                }

                #for(control in middle) {
                    <li class="page-item #if(current.page == control.page) { active }"><a href="#(control.url)" class="page-link">#(control.page)</a></li>
                }

                #if(right) {
                    <li class="disabled page-item"><a href="#" class="page-link">...</a></li>
                }

                #if(last) {
                    <li class="page-item #if(current.page == last.page) { active }"><a href="#(last.url)" class="page-link">#(last.page)</a></li>
                }

                <li class="#if(next == nil) { disabled } page-item">
                    <a #if(next) { href="#(next.url)" } class="page-link" rel="next" aria-label="Next">
                        <span aria-hidden="true">&raquo;</span>
                        <span class="sr-only">Next</span>
                    </a>
                </li>

            </ul>
        </nav>
        """
    }
}

extension HTML {
    struct Alert {
        let message: String
        let alertClass: AlertClass

        enum AlertClass: String {
            case primary
            case secondary
            case success
            case danger
            case warning
            case info
            case light
            case dark
        }
    }
}

extension HTML.Alert: HypertextLiteralConvertible {
    var html: HTML {
        """
        <div class="alert alert-\(alertClass.rawValue)" role="alert">
            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                <span aria-hidden="true">&times;</span>
            </button>
            \(message)
        </div>
        """
    }
}

extension HTML.Alert {
    init(_ error: Error) {
        let message: String
        switch error {
        case let error as AbortError:
            message = error.reason
        default:
            message = error.localizedDescription
        }

        self.init(message: message, alertClass: .warning)
    }
}

extension HTML {
    struct FormGroup {
        enum TypeAttribute: String {
            case checkbox
            case email
            case file
            case number
            case password
            case radio
            case text
        }

        let id: String
        let name: String
        let type: TypeAttribute
        let label: String?
        let placeholder: String?
        let value: String?
        let isValid: Bool?
        let isRequired: Bool
        let feedback: [String]
    }
}

extension HTML.FormGroup {
    init<T>(
        id: String,
        name: String,
        type: TypeAttribute = .text,
        label: String? = nil,
        placeholder: String? = nil,
        isRequired: Bool = true,
        validatedValue: ValidatedValue<T>?
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.label = label
        self.placeholder = placeholder
        self.isRequired = isRequired
        self.value = validatedValue?.value?.description
        self.feedback = validatedValue?.failureDescriptions ?? []
        self.isValid = validatedValue?.isValid
    }
}

extension Dictionary where Value == Any {
    func removeNilValues() -> Self {
        compactMapValues {
            switch $0 as Any {
            case Optional<Any>.none:
                return nil
            default:
                return $0
            }
        }
    }
}

extension HTML.FormGroup: HypertextLiteralConvertible {
    var html: HTML {
        let inputAttributes: [String: Any] = [
            "id": id,
            "name": name,
            "type": type.rawValue,
            "placeholder": placeholder as Any,
            "value": value as Any,
            "class": ["form-control", isValid.map { $0 ? "is-valid" : "is-invalid" } ?? ""],
            "required": isRequired
        ].removeNilValues()

        let feedback: HTML = self.feedback.isEmpty ? "" : """
        <div class="invalid-feedback">
            \(self.feedback.joined(separator: ", "))
        </div>
        """

        let label: HTML = self.label.map { #"<label for="\#(id)">\#($0)</label>"# } ?? ""

        return """
        <div class="form-group">
            \(label.html)
            <input \(inputAttributes)>
            \(feedback)
        </div>
        """
    }
}

extension HTML: ResponseEncodable {
    public func encodeResponse(for request: Request) -> EventLoopFuture<Response> {
        request.eventLoop.future(.init(body: .init(string: description)))
    }
}

extension Request {
    var html: HTMLViewRenderer {
        .init(config: .init(appName: "Template"))
    }
}

struct HTMLViewRenderer {
    struct Config {
        let appName: String
    }

    let config: Config

    func base(title: String, styles: [HTML] = [], body: HTML, scripts: [HTML] = []) -> HTML {
        """
        <!DOCTYPE html>
        <html lang="en">
            <head>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

                <title>\(title) | \(config.appName)</title>

                <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css" integrity="sha384-9aIt2nRpC12Uk9gS9baDl411NQApFmC26EwAOH8WgZl5MYYxFfc+NcPb1dKGj7Sk" crossorigin="anonymous">
                <link href="/admin-panel/css/dashboard.css" rel="stylesheet">

                \(styles)
            </head>

            <body>
                \(body)

                <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js" integrity="sha256-4+XzXVhsDmqanXGHaHvgh1gMQKX40OUvDEBTu8JcmNs=" crossorigin="anonymous"></script>
                <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/js/bootstrap.min.js" integrity="sha384-OgVRvuATP1z7JjHLkuOU7Xw704+h835Lr+6QL9UvYjZE3Ipu6Tp75j7Bh/kR0JKI" crossorigin="anonymous"></script>
                <script src="https://cdn.jsdelivr.net/npm/feather-icons/dist/feather.min.js"></script>
                <script src="/admin-panel/js/modal-confirmation.js"></script>

                <script>
                    feather.replace()

                    $(function () {
                        $('[data-toggle="tooltip"]').tooltip();
                    });
                </script>

                \(scripts)
            </body>
        </html>
        """
    }

    private func alertBlock(_ alerts: [HTML.Alert]) -> HTML {
        guard !alerts.isEmpty else { return "" }
        return """
        <div class="alerts">
            \(alerts.map(\.html))
        </div>
        """
    }

    func login(
        email: ValidatedValue<String>? = nil,
        password: ValidatedValue<String>? = nil,
        alerts: HTML.Alert ...
    ) -> HTML {
        base(
            title: "Login",
            styles: [#"<link href="/admin-panel/css/login.css" rel="stylesheet">"#],
            body:
            """
            <form class="form-signin" method="POST">
                <h1>\(config.appName)</h1>
                <h4>Please sign in</h4>
                \(alertBlock(alerts))

                \(HTML.FormGroup(
                    id: "email",
                    name: "email",
                    type: .email,
                    label: "Email address",
                    placeholder: "Enter email",
                    validatedValue: email
                ).html)
                \(HTML.FormGroup(
                    id: "password",
                    name: "password",
                    type: .password,
                    label: "Password",
                    placeholder: "Enter password",
                    validatedValue: password
                ).html)

                <p><a href="/admin/users/reset-password/request">Forgot your password?</a></p>

                <button type="submit" class="btn btn-primary btn-lg btn-block">Sign in</button>
            </form>
            """
        )
    }

    func dashboard() -> HTML {
        base(
            title: "Dashboard",
            body: """
            TO DO
            """
        )
    }
}

