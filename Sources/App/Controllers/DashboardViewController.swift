import HypertextLiteral
import Vapor

struct DashboardViewController {
    func renderDashboard(request: Request) -> HTML {
        request.html.dashboard(page: (try? request.query.get(Int.self, at: "page")) ?? 1)
    }
}

extension DashboardViewController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("", use: renderDashboard)
    }
}
