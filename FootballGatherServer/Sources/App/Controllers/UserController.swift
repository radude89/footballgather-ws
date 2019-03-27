import Vapor
import Crypto

struct UserController: RouteCollection {
    func boot(router: Router) throws {
        let userRoute = router.grouped("api", "users")
        userRoute.get(use: getAllHandler)
        userRoute.get(User.parameter, use: getHandler)
        userRoute.post(User.self, use: createHandler)
        userRoute.delete(User.parameter, use: deleteHandler)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).decode(data: User.self).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(User.self)
    }
    
    func createHandler(_ req: Request, user: User) throws -> Future<Response> {
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
        return try req.parameters.next(User.self).flatMap(to: HTTPStatus.self) { user in
            return user.delete(on: req).transform(to: .noContent)
        }
    }
}
