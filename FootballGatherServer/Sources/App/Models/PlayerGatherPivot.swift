import FluentSQLite
import Vapor

final class PlayerGatherPivot: SQLiteUUIDPivot {
    var id: UUID?
    var playerId: Player.ID
    var gatherId: Gather.ID
    var team: String
    
    typealias Left = Player
    typealias Right = Gather
    
    static var leftIDKey: LeftIDKey = \PlayerGatherPivot.playerId
    static var rightIDKey: RightIDKey = \PlayerGatherPivot.gatherId
    
    init(playerId: Player.ID, gatherId: Gather.ID, team: String) {
        self.playerId = playerId
        self.gatherId = gatherId
        self.team = team
    }
    
}

extension PlayerGatherPivot: Migration {}
