import Vapor
import FluentSQLiteDriver

// MARK: - Model
final class Player: Model {
    static let schema = "players"
    
    @ID(custom: .id)
    var id: Int?
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "name")
    var name: String
    
    @OptionalField(key: "age")
    var age: Int?
    
    @OptionalField(key: "skill")
    var skill: Skill?
    
    @OptionalField(key: "position")
    var preferredPosition: Position?
    
    @OptionalField(key: "favourite_team")
    var favouriteTeam: String?
    
    @Siblings(through: PlayerGatherPivot.self, from: \.$player, to: \.$gather)
    public var gathers: [Gather]
    
    convenience init() {
        self.init(userID: UUID(), name: "")
    }
    
    init(id: Int? = nil,
         userID: User.IDValue,
         name: String,
         age: Int? = nil,
         skill: Skill? = nil,
         preferredPosition: Position? = nil,
         favouriteTeam: String? = nil) {
        self.id = id
        self.$user.id = userID
        self.name = name
        self.age = age
        self.skill = skill
        self.preferredPosition = preferredPosition
        self.favouriteTeam = favouriteTeam
    }
}

extension Player: Content {}

// MARK: - Migration
extension Player: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Player.schema)
            .field("id", .int, .identifier(auto: true))
            .field("user_id", .uuid, .required, .references("users", "id"))
            .foreignKey("user_id", references: "users", "id", onDelete: .cascade)
            .field("name", .string, .required)
            .field("age", .int)
            .field("skill", .string)
            .field("position", .string)
            .field("favourite_team", .string)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Player.schema).delete()
    }
}

// MARK: - Enums
extension Player {
    enum Skill: String, Codable {
        case beginner, amateur, professional
    }
    
    enum Position: String, Codable {
        case goalkeeper, defender, midfielder, winger, striker
    }
}
