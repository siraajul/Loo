import Foundation
import SwiftData

@Model
final class Submission {
    @Attribute(.unique) var id: String
    var washroomId: String?          // nil = new submission
    var proposedDataJson: String     // JSON-encoded proposed changes
    var userId: String
    var statusRaw: String
    var moderatorNote: String?
    var createdAt: Date

    enum Status: String {
        case pending, approved, rejected
    }

    var status: Status { Status(rawValue: statusRaw) ?? .pending }

    init(id: String, washroomId: String? = nil, proposedDataJson: String,
         userId: String, status: Status = .pending,
         moderatorNote: String? = nil, createdAt: Date = .now) {
        self.id               = id
        self.washroomId       = washroomId
        self.proposedDataJson = proposedDataJson
        self.userId           = userId
        self.statusRaw        = status.rawValue
        self.moderatorNote    = moderatorNote
        self.createdAt        = createdAt
    }
}
