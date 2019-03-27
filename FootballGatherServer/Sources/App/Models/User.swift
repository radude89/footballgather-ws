import FluentSQLite
import Vapor
import Authentication

final class User {
    var id: UUID?
    var username: String
    var password: String
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    final class Public: Codable {
        var id: UUID?
        var username: String
        
        init(id: UUID?, username: String) {
            self.id = id
            self.username = username
        }
    }
}

extension User: SQLiteUUIDModel {}
extension User: Content {}
extension User: Parameter {}

extension User: Migration {
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return Database.create(self, on: conn) { (builder) in
            try addProperties(to: builder)
            builder.unique(on: \.username)
        }
    }
}

extension User {
    var players: Children<User, Player> {
        return children(\.userId)
    }
    
    var gathers: Children<User, Gather> {
        return children(\.userId)
    }
}

extension User.Public: Content {}

extension User {
    func toPublicUser() -> User.Public {
        return User.Public(id: id, username: username)
    }
}

extension Future where T: User {
    func toPublicUser() -> Future<User.Public> {
        return map(to: User.Public.self) { user in
            return user.toPublicUser()
        }
    }
}

extension User: BasicAuthenticatable {
    static let usernameKey: UsernameKey = \User.username
    static let passwordKey: PasswordKey = \User.password
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

extension User: PasswordAuthenticatable {}
extension User: SessionAuthenticatable {}
