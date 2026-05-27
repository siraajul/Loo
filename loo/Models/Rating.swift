import Foundation
import SwiftData

@Model
final class Rating {
    @Attribute(.unique) var id: String
    var washroomId: String
    var userId: String
    var cleanliness: Int
    var comment: String?
    var createdAt: Date

    init(id: String, washroomId: String, userId: String, cleanliness: Int,
         comment: String? = nil, createdAt: Date = .now) {
        self.id          = id
        self.washroomId  = washroomId
        self.userId      = userId
        self.cleanliness = cleanliness
        self.comment     = comment
        self.createdAt   = createdAt
    }
}
