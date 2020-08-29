import Vapor
import FluentSQLiteDriver

// MARK: - Model
final class PlayerGatherPivot: Model {
    static let schema = "player_gather"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "player_id")
    var player: Player
    
    @Parent(key: "gather_id")
    var gather: Gather

    @Field(key: "team")
    var team: String
    
    init() {}

    init(playerID: Player.IDValue,
         gatherID: Gather.IDValue,
         team: String) {
        self.$player.id = playerID
        self.$gather.id = gatherID
        self.team = team
    }
    
}

// MARK: - Migration
extension PlayerGatherPivot: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PlayerGatherPivot.schema)
            .field("id", .uuid, .identifier(auto: true))
            .field("player_id", .int, .required)
            .field("gather_id", .uuid, .required)
            .field("team", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PlayerGatherPivot.schema).delete()
    }
}
