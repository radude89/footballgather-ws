import Vapor
import Crypto

struct PlayerController: RouteCollection {
    func boot(router: Router) throws {
        let playerRoute = router.grouped("api", "players")
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardMiddelware = User.guardAuthMiddleware()
        let tokenAuthGroup = playerRoute.grouped(tokenAuthMiddleware, guardMiddelware)
        
        tokenAuthGroup.post(PlayerCreateData.self, use: createHandler)
        tokenAuthGroup.delete(Player.parameter, use: deleteHandler)
        tokenAuthGroup.put(Player.parameter, use: updateHandler)
        tokenAuthGroup.get(Player.parameter, "gathers", use: getGathersHandler)
        tokenAuthGroup.get(use: getPlayersHandler)
    }
    
    func getPlayersHandler(_ req: Request) throws -> Future<[Player]> {
        let user = try req.requireAuthenticated(User.self)
        return try user.players.query(on: req).all()
    }
    
    func createHandler(_ req: Request, playerCreateData: PlayerCreateData) throws -> Future<Response> {
        let user = try req.requireAuthenticated(User.self)
        let player = try Player(userId: user.requireID(), name: playerCreateData.name, age: playerCreateData.age, skill: playerCreateData.skill, preferredPosition: playerCreateData.preferredPosition, favouriteTeam: playerCreateData.favouriteTeam)
        
        return player.save(on: req).map { player in
            var httpResponse = HTTPResponse()
            httpResponse.status = .created
            
            if let playerId = player.id {
                let location = req.http.url.path + "/\(playerId)"
                httpResponse.headers.replaceOrAdd(name: "Location", value: location)
            }
            
            let response = Response(http: httpResponse, using: req)
            return response
        }
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.requireAuthenticated(User.self)
        return try flatMap(to: HTTPStatus.self,
                           req.parameters.next(Player.self),
                           user.players.query(on: req).all()) { player, players in
                            
                            for aPlayer in players {
                                if aPlayer.id == player.id {
                                    return player.delete(on: req).transform(to: .noContent)
                                }
                            }
                            
                            throw Abort(.notFound)
        }
    }
    
    func updateHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.requireAuthenticated(User.self)
        return try flatMap(to: HTTPStatus.self,
                           req.parameters.next(Player.self),
                           req.content.decode(PlayerCreateData.self),
                           user.players.query(on: req).all()) { player, updatedPlayer, players in
                            
                            for aPlayer in players {
                                if aPlayer.id == player.id {
                                    player.age = updatedPlayer.age
                                    player.name = updatedPlayer.name
                                    player.preferredPosition = updatedPlayer.preferredPosition
                                    player.favouriteTeam = updatedPlayer.favouriteTeam
                                    player.skill = updatedPlayer.skill
                                    
                                    let user = try req.requireAuthenticated(User.self)
                                    player.userId = try user.requireID()
                                    
                                    return player.save(on: req).transform(to: .noContent)
                                }
                            }
                            
                            throw Abort(.notFound)
        }
    }
    
    func getGathersHandler(_ req: Request) throws -> Future<[Gather]> {
        let user = try req.requireAuthenticated(User.self)
        return try flatMap(to: [Gather].self,
                           req.parameters.next(Player.self),
                           user.players.query(on: req).all()) { player, players in
                            
                            for aPlayer in players {
                                if aPlayer.id == player.id {
                                    return try req.parameters.next(Player.self).flatMap(to: [Gather].self) { player in
                                        return try player.gathers.query(on: req).all()
                                    }
                                }
                            }
                            
                            throw Abort(.notFound)
        }
        
    }
}

struct PlayerCreateData: Content {
    var name: String
    var age: Int?
    var skill: Player.Skill?
    var preferredPosition: Player.Position?
    var favouriteTeam: String?
}
