import FluentSQLite
import Vapor

final class User {
    var id: UUID?
    var username: String
    var password: String
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}

extension User: SQLiteUUIDModel {}
extension User: Content {}
extension User: Migration {}
extension User: Parameter {}
