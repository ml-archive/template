import HypertextLiteral
import Vapor

struct DashboardViewController {
    func renderDashboard(request: Request) throws -> HTML {
        // hard-code total number of results for demo purposes
        try request.html.dashboard(url: request.url, totalResults: 153)
    }
}

extension DashboardViewController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("", use: renderDashboard)
    }
}
