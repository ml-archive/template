import MySQLProvider
import RedisProvider
import Bugsnag

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setupProviders()
        try setupMiddlewares()
        try setupPreparations()
        try setupCommands()
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(MySQLProvider.Provider.self)
        try addProvider(RedisProvider.Provider.self)
        try addProvider(Bugsnag.Provider.self)
    }

    /// Configre middlewares
    private func setupMiddlewares() throws {
        addConfigurable(middleware: Bugsnag.Middleware.init, name: "bugsnag")
    }
    
    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {
        preparations.append(Post.self)
    }

    /// Configure commands
    private func setupCommands() throws {
        // Add commands here by calling addConfigurable()
    }
}
