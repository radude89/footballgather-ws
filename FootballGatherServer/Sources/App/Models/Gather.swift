import Vapor
import FluentSQLiteDriver

// MARK: - Model
final class Gather: Model {
    static let schema = "gathers"
    
    @ID(key: "id")
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @OptionalField(key: "score")
    var score: String?
    
    @OptionalField(key: "winner_team")
    var winnerTeam: String?
    
    @Siblings(through: PlayerGatherPivot.self, from: \.$gather, to: \.$player)
    var players: [Player]
    
    init() {}
    
    init(id: UUID? = nil,
         userID: User.IDValue,
         score: String? = nil,
         winnerTeam: String? = nil) {
        self.id = id
        self.$user.id = userID
        self.score = score
        self.winnerTeam = winnerTeam
    }
    
}

extension Gather: Content {}

// MARK: - Migration
extension Gather: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Gather.schema)
            .field("id", .uuid, .identifier(auto: true))
            .field("user_id", .uuid, .required, .references("users", "id"))
            .foreignKey("user_id", references: "users", "id", onDelete: .cascade)
            .field("score", .string)
            .field("winner_team", .string)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Gather.schema).delete()
    }
}
