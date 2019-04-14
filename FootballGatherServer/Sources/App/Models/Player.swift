import FluentSQLite
import Vapor

final class Player: Codable {
    var id: Int?
    var userId: User.ID
    var name: String
    var age: Int
    var skill: Skill?
    var preferredPosition: Position?
    var favouriteTeam: String?
    
    enum Skill: String, Codable {
        case beginner, amateur, professional
    }
    
    enum Position: String, Codable {
        case goalkeeper, defender, midfielder, winger, striker
    }
    
    init(userId: User.ID, name: String, age: Int, skill: Skill?, preferredPosition: Position?, favouriteTeam: String?) {
        self.userId = userId
        self.name = name
        self.age = age
        self.skill = skill
        self.preferredPosition = preferredPosition
        self.favouriteTeam = favouriteTeam
    }
    
    init(from decoder: Decoder) throws  {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let id = try container.decodeIfPresent(Int.self, forKey: .id) {
            self.id = id
        }
        
        userId = try container.decode(UUID.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)
        age = try container.decode(Int.self, forKey: .age)
        favouriteTeam = try container.decodeIfPresent(String.self, forKey: .favouriteTeam)
        
        if let skillDesc = try container.decodeIfPresent(String.self, forKey: .skill) {
            skill = Skill(rawValue: skillDesc)
        }
        
        if let posDesc = try container.decodeIfPresent(String.self, forKey: .preferredPosition) {
            preferredPosition = Position(rawValue: posDesc)
        }
    }
}

extension Player: SQLiteModel {}
extension Player: Content {}
extension Player: Migration {}
extension Player: Parameter {}

extension Player {
    var user: Parent<Player, User> {
        return parent(\.userId)
    }
    
    var gathers: Siblings<Player, Gather, PlayerGatherPivot> {
        return siblings()
    }
}
