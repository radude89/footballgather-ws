import Vapor
import Fluent

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userRoute = routes.grouped("api", "users")
        userRoute.get(use: getAllHandler)
        userRoute.get(":id", use: getHandler)
        userRoute.post(use: createHandler)
        
        let basicAuthMiddleware = User.authenticator()
        let guardMiddleware = User.guardMiddleware()
        let basicAuthGroup = userRoute.grouped(basicAuthMiddleware, guardMiddleware)
        basicAuthGroup.post("login", use: loginHandler)

        let tokenAuthMiddleware = Token.authenticator()
        let tokenAuthGroup = userRoute.grouped(tokenAuthMiddleware, guardMiddleware)
        tokenAuthGroup.delete(use: deleteHandler)
    }
    
    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[User.Public]> {
        User.query(on: req.db)
            .all()
            .flatMapEachThrowing { try User.Public(id: $0.requireID(), username: $0.username) }
    }
    
    func getHandler(_ req: Request) throws -> EventLoopFuture<User.Public> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        return User.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing { $0.toPublicUser() }
    }
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let user = try req.content.decode(User.self)
        user.password = try Bcrypt.hash(user.password)
        
        return user.save(on: req.db).map {
            let response = Response()
            response.status = .created
                        
            if let userID = user.id?.description {
                let location = req.url.path + "/" + userID
                response.headers.replaceOrAdd(name: "Location", value: location)
            }
            
            return response
        }
    }
    
    func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let user = try req.auth.require(User.self)
        return user.delete(on: req.db).transform(to: HTTPStatus.noContent)
    }
    
    func loginHandler(_ req: Request) throws -> EventLoopFuture<TokenResponse> {
        let user = try req.auth.require(User.self)
        let token = try user.generateToken()
        
        return token.save(on: req.db).flatMapThrowing {
            try TokenResponse(token: token.token,
                              userID: user.requireID())
        }
    }
}

// MARK: - Request models
struct TokenResponse: Content {
    let token: String
    let userID: UUID
}
