import FluentSQLite
import Vapor
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentSQLiteProvider())
    try services.register(AuthenticationProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self)
    services.register(middlewares)

    // Configure a SQLite database
    let sqlite = try SQLiteDatabase(storage: .memory)

    // Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: DatabaseIdentifier<User.Database>.sqlite)
    migrations.add(model: Player.self, database: DatabaseIdentifier<Player.Database>.sqlite)
    migrations.add(model: Gather.self, database: DatabaseIdentifier<Gather.Database>.sqlite)
    migrations.add(model: PlayerGatherPivot.self, database: DatabaseIdentifier<PlayerGatherPivot.Database>.sqlite)
    migrations.add(model: Token.self, database: DatabaseIdentifier<Token.Database>.sqlite)
    services.register(migrations)
    
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
}
