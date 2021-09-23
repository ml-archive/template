import NMeta
import Vapor

extension Application.NMeta {
    mutating func configure() {
        exceptPaths = ["/health",]
    }
}
