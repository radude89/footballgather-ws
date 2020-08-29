import Vapor
import Fluent
import FluentSQLiteDriver

public func configure(_ app: Application) throws {
    app.databases.use(.sqlite(.memory), as: .sqlite)
    
    app.migrations.add(User())
    app.migrations.add(Token())
    app.migrations.add(Gather())
    app.migrations.add(Player())
    app.migrations.add(PlayerGatherPivot())
    
    try app.autoMigrate().wait()

    try routes(app)
}

