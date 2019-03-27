import Vapor
import Crypto

struct PlayerController: RouteCollection {
    func boot(router: Router) throws {
        let playerRoute = router.grouped("api", "players")
        playerRoute.get(use: getAllHandler)
        playerRoute.get(Player.parameter, use: getHandler)
        playerRoute.post(Player.self, use: createHandler)
        playerRoute.delete(Player.parameter, use: deleteHandler)
        playerRoute.put(Player.parameter, use: updateHandler)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Player]> {
        return Player.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<Player> {
        return try req.parameters.next(Player.self)
    }
    
    func createHandler(_ req: Request, player: Player) -> Future<Response> {
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
        return try req.parameters.next(Player.self).flatMap(to: HTTPStatus.self) { player in
            return player.delete(on: req).transform(to: .noContent)
        }
    }
    
    func updateHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self, req.parameters.next(Player.self), req.content.decode(Player.self)) { player, updatedPlayer in
            player.age = updatedPlayer.age
            
            if let favouriteTeam = updatedPlayer.favouriteTeam {
                player.favouriteTeam = favouriteTeam
            }
            
            if let preferredPosition = updatedPlayer.preferredPosition {
                player.preferredPosition = preferredPosition
            }
            
            if let skill = updatedPlayer.skill {
                player.skill = skill
            }
            
            return player.save(on: req).transform(to: .noContent)
        }
    }
}
