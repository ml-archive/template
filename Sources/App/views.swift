import Leaf
import Vapor

func views(_ app: Application) {
    app.views.use(.leaf)
}
