import Leaf
import Vapor

extension Application.Views {
    func configure() {
        use(.leaf)
    }
}
