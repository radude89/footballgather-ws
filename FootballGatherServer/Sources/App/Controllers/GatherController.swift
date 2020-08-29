import Vapor
import Fluent

// MARK: - Controller
struct GatherController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let gatherRoute = routes.grouped("api", "gathers")
        let tokenAuthMiddleware = Token.authenticator()
        let guardMiddleware = User.guardMiddleware()
        let tokenAuthGroup = gatherRoute.grouped(tokenAuthMiddleware, guardMiddleware)
        
        tokenAuthGroup.get(use: getGathersHandler)
        tokenAuthGroup.post(use: createHandler)
        tokenAuthGroup.delete(":id", use: deleteHandler)
        tokenAuthGroup.put(":id", use: updateHandler)
        tokenAuthGroup.post(":gatherID", "players", ":playerID", use: addPlayerHandler)
        tokenAuthGroup.get(":id", "players", use: getPlayersHandler)
    }
    
    func getGathersHandler(_ req: Request) throws -> EventLoopFuture<[GatherResponseData]> {
        let user = try req.auth.require(User.self)
        return user.$gathers.query(on: req.db)
            .all()
            .flatMapEachThrowing {
                try GatherResponseData(
                    id: $0.requireID(),
                    userId: user.requireID(),
                    score: $0.score,
                    winnerTeam: $0.winnerTeam
                )}
    }
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let user = try req.auth.require(User.self)
        let gather = try Gather(userID: user.requireID())
        
        return gather.save(on: req.db).map {
            let response = Response()
            response.status = .created
                        
            if let gatherID = gather.id?.description {
                let location = req.url.path + "/" + gatherID
                response.headers.replaceOrAdd(name: "Location", value: location)
            }
            
            return response
        }
    }
    
    func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let user = try req.auth.require(User.self)
        
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        return user.$gathers.get(on: req.db).flatMap { gathers in
            if let gather = gathers.first(where: { $0.id == id }) {
                return gather.delete(on: req.db).transform(to: HTTPStatus.noContent)
            }
            
            return req.eventLoop.makeFailedFuture(Abort(.notFound))
        }
    }
    
    func updateHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let user = try req.auth.require(User.self)
        let gatherUpdateDate = try req.content.decode(GatherUpdateData.self)
        
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        return user.$gathers.get(on: req.db).flatMap { gathers in
            guard let gather = gathers.first(where: { $0.id == id }) else {
                return req.eventLoop.makeFailedFuture(Abort(.notFound))
            }
                
            gather.score = gatherUpdateDate.score
            gather.winnerTeam = gatherUpdateDate.winnerTeam
            
            return gather.save(on: req.db).transform(to: HTTPStatus.noContent)
        }
    }
    
    func addPlayerHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let user = try req.auth.require(User.self)
        let playerGatherData = try req.content.decode(PlayerGatherData.self)
        
        guard let gatherID = req.parameters.get("gatherID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let playerID = req.parameters.get("playerID", as: Int.self) else {
            throw Abort(.badRequest)
        }
        
        let gather = user.$gathers.query(on: req.db)
            .filter(\.$id == gatherID)
            .first()
        
        let player = user.$players.query(on: req.db)
            .filter(\.$id == playerID)
            .first()
        
        return gather.and(player).flatMap { _ in
            let pivot = PlayerGatherPivot(playerID: playerID,
                                          gatherID: gatherID,
                                          team: playerGatherData.team)
            
            return pivot.save(on: req.db).transform(to: HTTPStatus.ok)
        }
    }
    
    func getPlayersHandler(_ req: Request) throws -> EventLoopFuture<[PlayerResponseData]> {
        let user = try req.auth.require(User.self)
        
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        return user.$gathers.get(on: req.db).flatMap { gathers in
            guard let gather = gathers.first(where: { $0.id == id }) else {
                return req.eventLoop.makeFailedFuture(Abort(.notFound))
            }
            
            return gather.$players.query(on: req.db)
                .all()
                .flatMapEachThrowing {
                    try PlayerResponseData(
                        id: $0.requireID(),
                        name: $0.name,
                        age: $0.age,
                        skill: $0.skill,
                        preferredPosition: $0.preferredPosition,
                        favouriteTeam: $0.favouriteTeam
                    )}
        }
    }
}

// MARK: - Request models
struct GatherResponseData: Content {
    let id: UUID
    let userId: UUID
    let score: String?
    let winnerTeam: String?
}

struct GatherCreateData: Content {
    let score: String?
    let winnerTeam: String?
}

struct GatherUpdateData: Content {
    let score: String
    let winnerTeam: String
}

struct PlayerGatherData: Content {
    let team: String
}
