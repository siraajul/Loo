import Foundation

struct UserProfile: Codable, Sendable {
    let id: String
    let phone: String?
    let displayName: String?
    let avatarURL: URL?
    let isVerified: Bool
    let submissionCount: Int
    let createdAt: Date

    var initials: String {
        guard let name = displayName else { return "?" }
        return name.split(separator: " ")
            .compactMap(\.first)
            .prefix(2)
            .map(String.init)
            .joined()
    }
}
