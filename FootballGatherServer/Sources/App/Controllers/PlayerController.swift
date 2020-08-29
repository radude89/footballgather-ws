import Vapor

// MARK: - Controller
struct PlayerController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let playerRoute = routes.grouped("api", "players")
        let tokenAuthMiddleware = Token.authenticator()
        let guardMiddleware = User.guardMiddleware()
        let tokenAuthGroup = playerRoute.grouped(tokenAuthMiddleware, guardMiddleware)
        
        tokenAuthGroup.post(use: createHandler)
        tokenAuthGroup.delete(":id", use: deleteHandler)
        tokenAuthGroup.put(":id", use: updateHandler)
        tokenAuthGroup.get(":id", "gathers", use: getGathersHandler)
        tokenAuthGroup.get(use: getPlayersHandler)
    }
    
    func getPlayersHandler(_ req: Request) throws -> EventLoopFuture<[PlayerResponseData]> {
        let user = try req.auth.require(User.self)
        return user.$players.query(on: req.db).all().flatMapEachThrowing {
            try PlayerResponseData(id: $0.requireID(),
                                   name: $0.name,
                                   age: $0.age,
                                   skill: $0.skill,
                                   preferredPosition: $0.preferredPosition,
                                   favouriteTeam: $0.favouriteTeam)
        }
    }
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let playerCreateData = try req.content.decode(PlayerCreateData.self)
        let user = try req.auth.require(User.self)
        let player = try Player(userID: user.requireID(),
                                name: playerCreateData.name,
                                age: playerCreateData.age,
                                skill: playerCreateData.skill,
                                preferredPosition: playerCreateData.preferredPosition,
                                favouriteTeam: playerCreateData.favouriteTeam)
        
        return player.save(on: req.db).map {
            let response = Response()
            response.status = .created
            
            if let playerID = player.id?.description {
                let location = req.url.path + "/" + playerID
                response.headers.replaceOrAdd(name: "Location", value: location)
            }
            
            return response
        }
    }
    
    func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let user = try req.auth.require(User.self)
        
        guard let id = req.parameters.get("id", as: Int.self) else {
            throw Abort(.badRequest)
        }
        
        return user.$players.get(on: req.db).flatMap { players in
            if let player = players.first(where: { $0.id == id }) {
                return player.delete(on: req.db).transform(to: HTTPStatus.noContent)
            }
            
            return req.eventLoop.makeFailedFuture(Abort(.notFound))
        }
    }
    
    func updateHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let user = try req.auth.require(User.self)
        let playerCreateData = try req.content.decode(PlayerCreateData.self)
        
        guard let id = req.parameters.get("id", as: Int.self) else {
            throw Abort(.badRequest)
        }
        
        return user.$players.get(on: req.db).flatMap { players in
            guard let player = players.first(where: { $0.id == id }) else {
                return req.eventLoop.makeFailedFuture(Abort(.notFound))
            }
            
            player.age = playerCreateData.age
            player.name = playerCreateData.name
            player.preferredPosition = playerCreateData.preferredPosition
            player.favouriteTeam = playerCreateData.favouriteTeam
            player.skill = playerCreateData.skill
            
            return player.save(on: req.db).transform(to: HTTPStatus.noContent)
        }
    }
    
    func getGathersHandler(_ req: Request) throws -> EventLoopFuture<[GatherResponseData]> {
        let user = try req.auth.require(User.self)
        
        guard let id = req.parameters.get("id", as: Int.self) else {
            throw Abort(.badRequest)
        }
        
        return user.$players.get(on: req.db).flatMap { players in
            guard let player = players.first(where: { $0.id == id }) else {
                return req.eventLoop.makeFailedFuture(Abort(.notFound))
            }
            
            return player.$gathers.query(on: req.db)
                .all()
                .flatMapEachThrowing {
                    try GatherResponseData(
                        id: $0.requireID(),
                        userId: user.requireID(),
                        score: $0.score,
                        winnerTeam: $0.winnerTeam
                    )}
        }
    }
}

// MARK: - Request models
struct PlayerResponseData: Content {
    let id: Int
    let name: String
    let age: Int?
    let skill: Player.Skill?
    let preferredPosition: Player.Position?
    let favouriteTeam: String?
}

struct PlayerCreateData: Content {
    let name: String
    let age: Int?
    let skill: Player.Skill?
    let preferredPosition: Player.Position?
    let favouriteTeam: String?
}
