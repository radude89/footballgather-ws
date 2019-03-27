import Vapor
import Crypto

struct UserController: RouteCollection {
    func boot(router: Router) throws {
        let userRoute = router.grouped("api", "users")
        userRoute.get(use: getAllHandler)
        userRoute.get(User.parameter, use: getHandler)
        userRoute.post(User.self, use: createHandler)
        
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let guardMiddleware = User.guardAuthMiddleware()
        let basicAuthGroup = userRoute.grouped(basicAuthMiddleware, guardMiddleware)
        basicAuthGroup.post("login", use: loginHandler)
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenAuthGroup = userRoute.grouped(tokenAuthMiddleware, guardMiddleware)
        tokenAuthGroup.delete(use: deleteHandler)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[User.Public]> {
        return User.query(on: req).decode(data: User.Public.self).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(User.self).toPublicUser()
    }
    
    func createHandler(_ req: Request, user: User) throws -> Future<Response> {
        user.password = try BCrypt.hash(user.password)
        return user.save(on: req).map { user in
            var httpResponse = HTTPResponse()
            httpResponse.status = .created
            
            if let userId = user.id?.description {
                let location = req.http.url.path + "/" + userId
                httpResponse.headers.replaceOrAdd(name: "Location", value: location)
            }
            
            let response = Response(http: httpResponse, using: req)
            return response
        }
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.requireAuthenticated(User.self)
        return user.delete(on: req).transform(to: .noContent)
    }
    
    func loginHandler(_ req: Request) throws -> Future<Token> {
        let user = try req.requireAuthenticated(User.self)
        let token = try Token.generate(for: user)
        
        return token.save(on: req)
    }
    
}
