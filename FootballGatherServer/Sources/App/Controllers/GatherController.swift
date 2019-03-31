import Vapor
import Crypto

struct GatherController: RouteCollection {
    func boot(router: Router) throws {
        let gatherRoute = router.grouped("api", "gathers")
        gatherRoute.get(use: getAllHandler)
        gatherRoute.get(Gather.parameter, use: getHandler)
        gatherRoute.post(Gather.self, use: createHandler)
        gatherRoute.delete(Gather.parameter, use: deleteHandler)
        gatherRoute.put(Gather.parameter, use: updateHandler)
        gatherRoute.post(Gather.parameter, "players", Player.parameter, use: addPlayerHandler)
        gatherRoute.get(Gather.parameter, "players", use: getPlayersHandler)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Gather]> {
        return Gather.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<Gather> {
        return try req.parameters.next(Gather.self)
    }
    
    func createHandler(_ req: Request, gather: Gather) throws -> Future<Response> {
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
        return try req.parameters.next(Gather.self).flatMap(to: HTTPStatus.self) { gather in
            return gather.delete(on: req).transform(to: .noContent)
        }
    }
    
    func updateHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self, req.parameters.next(Gather.self), req.content.decode(GatherUpdateData.self)) { gather, updatedGather in
            gather.score = updatedGather.score
            gather.winnerTeam = updatedGather.winnerTeam
            
            return gather.save(on: req).transform(to: .noContent)
        }
    }
    
    func addPlayerHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self, req.parameters.next(Gather.self), req.parameters.next(Player.self), req.content.decode(PlayerGatherData.self)) { gather, player, playerGather in
            
            let pivot = try PlayerGatherPivot(playerId: player.requireID(), gatherId: gather.requireID(), team: playerGather.team)
            return pivot.save(on: req).transform(to: .ok)
        }
    }
    
    func getPlayersHandler(_ req: Request) throws -> Future<[Player]> {
        return try req.parameters.next(Gather.self).flatMap(to: [Player].self) { gather in
            return try gather.players.query(on: req).all()
        }
    }
    
}

struct GatherUpdateData: Content {
    let score: String
    let winnerTeam: String
}

struct PlayerGatherData: Content {
    let team: String
}
