import HypertextLiteral
import Vapor

struct DashboardViewController {
    func renderDashboard(request: Request) -> HTML {
        request.html.dashboard()
    }
}

extension DashboardViewController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("", use: renderDashboard)
    }
}
