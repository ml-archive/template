import HypertextLiteral
import Vapor

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
            case Optional<Any>.some(let value):
                return value
            default:
                return $0
            }
        }
    }
}

struct Attributes {
    private let dictionary: [String: Any]
}

extension Attributes: HypertextAttributesInterpolatable {
    func html(in element: String) -> HTML {
        dictionary.html(in: element)
    }
}

extension Attributes: ExpressibleByDictionaryLiteral {
    init(dictionaryLiteral elements: (String, Any)...) {
        self.dictionary = Dictionary(uniqueKeysWithValues: elements).removeNilValues()
    }
}

extension HTML.FormGroup: HypertextLiteralConvertible {
    var html: HTML {
        let inputAttributes: Attributes = [
            "id": id,
            "name": name,
            "type": type.rawValue,
            "placeholder": placeholder as Any,
            "value": value as Any,
            "class": ["form-control", isValid.map { $0 ? "is-valid" : "is-invalid" } ?? ""],
            "required": isRequired
        ]

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

    func dashboard(url: URI, totalResults: Int) throws -> HTML {
        let paginatorBar = try OffsetPaginatorControlData(url: url, totalResults: totalResults)

        return base(
            title: "Dashboard",
            body: """
            \(paginatorBar.html)
            """
        )
    }
}
