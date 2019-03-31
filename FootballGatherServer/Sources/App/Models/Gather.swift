import FluentSQLite
import Vapor

final class Gather: Codable {
    var id: UUID?
    var userId: User.ID
    var score: String?
    var winnerTeam: String?
    
    init(userId: User.ID, score: String? = nil, winnerTeam: String? = nil) {
        self.userId = userId
        self.score = score
        self.winnerTeam = winnerTeam
    }
    
}

extension Gather: SQLiteUUIDModel {}
extension Gather: Content {}
extension Gather: Migration {}
extension Gather: Parameter {}

extension Gather {
    var user: Parent<Gather, User> {
        return parent(\.userId)
    }
    
    var players: Siblings<Gather, Player, PlayerGatherPivot> {
        return siblings()
    }
}
