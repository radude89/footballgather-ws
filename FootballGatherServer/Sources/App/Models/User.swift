import Fluent
import Vapor

// MARK: - Model
final class User: Model {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "password")
    var password: String
    
    @Children(for: \.$user)
    var gathers: [Gather]
    
    @Children(for: \.$user)
    var players: [Player]
    
    init() {}
    
    init(id: UUID? = nil,
         username: String,
         password: String) {
        self.id = id
        self.username = username
        self.password = password
    }
    
}

extension User: Content {}

// MARK: - Migration
extension User: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema)
            .id()
            .field("username", .string, .required)
            .field("password", .string, .required)
            .unique(on: "username")
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema).delete()
    }
}

// MARK: - Public User
extension User {
    final class Public {
        var id: UUID?
        var username: String
        
        init(id: UUID?, username: String) {
            self.id = id
            self.username = username
        }
        
    }
}

extension User.Public: Content {}

extension User {
    func toPublicUser() -> User.Public {
        return User.Public(id: id, username: username)
    }
}

// MARK: - Auth
extension User: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("username", as: String.self, is: !.empty)
        validations.add("password", as: String.self, is: .count(3...))
    }
}

extension User: ModelAuthenticatable {
    static var usernameKey = \User.$username
    static var passwordHashKey = \User.$password
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}

extension User {
    func generateToken() throws -> Token {
        try .init(
            token: [UInt8].random(count: 16).base64,
            userID: self.requireID()
        )
    }
}

extension User: ModelSessionAuthenticatable {}
