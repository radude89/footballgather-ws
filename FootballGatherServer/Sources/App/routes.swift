import Vapor
import Fluent

func routes(_ app: Application) throws {
    let userController = UserController()
    try app.routes.register(collection: userController)
    
    let playerController = PlayerController()
    try app.routes.register(collection: playerController)
    
    let gatherController = GatherController()
    try app.routes.register(collection: gatherController)
}
