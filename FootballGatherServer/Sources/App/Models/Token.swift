import Vapor
import Fluent

// MARK: - Model
final class Token: Model {
    static let schema = "tokens"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "token")
    var token: String
    
    @Parent(key: "user_id")
    var user: User
    
    init() {}
    
    init(id: UUID? = nil,
         token: String,
         userID: User.IDValue) {
        self.id = id
        self.token = token
        self.$user.id = userID
    }
}

extension Token: Content {}

// MARK: - Migration
extension Token: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Token.schema)
            .id()
            .field("token", .string, .required)
            .field("user_id", .uuid, .required, .references("users", "id"))
            .foreignKey("user_id", references: "users", "id", onDelete: .cascade)
            .unique(on: "token")
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Token.schema).delete()
    }
}

// MARK: - Authenticable
extension Token: ModelTokenAuthenticatable {
    static let valueKey = \Token.$token
    static let userKey = \Token.$user
    
    var isValid: Bool { true }
}
