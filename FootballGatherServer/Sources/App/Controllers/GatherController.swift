import Vapor
import Crypto

struct GatherController: RouteCollection {
    func boot(router: Router) throws {
        let gatherRoute = router.grouped("api", "gathers")
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardMiddelware = User.guardAuthMiddleware()
        let tokenAuthGroup = gatherRoute.grouped(tokenAuthMiddleware, guardMiddelware)
        
        tokenAuthGroup.get(use: getGathersHandler)
        tokenAuthGroup.post(GatherCreateData.self, use: createHandler)
        tokenAuthGroup.delete(Gather.parameter, use: deleteHandler)
        tokenAuthGroup.put(Gather.parameter, use: updateHandler)
        tokenAuthGroup.post(Gather.parameter, "players", Player.parameter, use: addPlayerHandler)
        tokenAuthGroup.get(Gather.parameter, "players", use: getPlayersHandler)
    }
    
    func getGathersHandler(_ req: Request) throws -> Future<[Gather]> {
        let user = try req.requireAuthenticated(User.self)
        return try user.gathers.query(on: req).all()
    }
    
    func createHandler(_ req: Request, gatherCreateData: GatherCreateData) throws -> Future<Response> {
        let user = try req.requireAuthenticated(User.self)
        let gather = try Gather(userId: user.requireID(), score: gatherCreateData.score, winnerTeam: gatherCreateData.winnerTeam)
        
        return gather.save(on: req).map { gather in
            var httpResponse = HTTPResponse()
            httpResponse.status = .created
            
            if let gatherId = gather.id?.description {
                let location = req.http.url.path + "/" + gatherId
                httpResponse.headers.replaceOrAdd(name: "Location", value: location)
            }
            
            let response = Response(http: httpResponse, using: req)
            return response
        }
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.requireAuthenticated(User.self)
        return try flatMap(to: HTTPStatus.self,
                           req.parameters.next(Gather.self),
                           user.gathers.query(on: req).all()) { gather, gathers in
                            
                            for aGather in gathers {
                                if aGather.id == gather.id {
                                    return gather.delete(on: req).transform(to: .noContent)
                                }
                            }
                            
                            throw Abort(.notFound)
        }
    }
    
    func updateHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.requireAuthenticated(User.self)
        return try flatMap(to: HTTPStatus.self,
                           req.parameters.next(Gather.self),
                           req.content.decode(GatherUpdateData.self),
                           user.gathers.query(on: req).all()) { gather, updatedGather, gathers in
                            
                            for aGather in gathers {
                                if aGather.id == gather.id {
                                    gather.score = updatedGather.score
                                    gather.winnerTeam = updatedGather.winnerTeam
                                    
                                    let user = try req.requireAuthenticated(User.self)
                                    gather.userId = try user.requireID()
                                    
                                    return gather.save(on: req).transform(to: .noContent)
                                }
                            }
                            
                            throw Abort(.notFound)
        }
    }
    
    func addPlayerHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.requireAuthenticated(User.self)
        return try flatMap(to: HTTPStatus.self,
                           req.parameters.next(Gather.self),
                           req.parameters.next(Player.self),
                           req.content.decode(PlayerGatherData.self),
                           user.gathers.query(on: req).all()) { gather, player, playerGather, gathers in
                            
                            for aGather in gathers {
                                if aGather.id == gather.id {
                                    let pivot = try PlayerGatherPivot(playerId: player.requireID(), gatherId: gather.requireID(), team: playerGather.team)
                                    return pivot.save(on: req).transform(to: .ok)
                                }
                            }
                            
                            throw Abort(.notFound)
        }
    }
    
    func getPlayersHandler(_ req: Request) throws -> Future<[Player]> {
        let user = try req.requireAuthenticated(User.self)
        
        return try flatMap(to: [Player].self,
                           req.parameters.next(Gather.self),
                           user.gathers.query(on: req).all()) { gather, gathers in
                            
                            for aGather in gathers {
                                if aGather.id == gather.id {
                                    return try gather.players.query(on: req).all()
                                }
                            }
                            
                            throw Abort(.notFound)
        }
    }
    
}

struct GatherCreateData: Content {
    var score: String?
    var winnerTeam: String?
}

struct GatherUpdateData: Content {
    let score: String
    let winnerTeam: String
}

struct PlayerGatherData: Content {
    let team: String
}
