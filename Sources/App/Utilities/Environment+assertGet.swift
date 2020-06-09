import Vapor

extension Environment {
    public static func assertGet(_ key: String) -> String {
        guard let value = ProcessInfo.processInfo.environment[key] else {
            fatalError(#"Missing environment key: \#(key)"#)
        }
        return value
    }
}
