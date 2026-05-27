import Foundation

struct ProposedWashroomData: Encodable, Sendable {
    var name: String
    var nameBn: String?
    var type: String
    var gender: String
    var accessible: Bool
    var feeBdt: Int
    var latitude: Double
    var longitude: Double
    var notes: String?
}

struct SubmissionPayload: Encodable, Sendable {
    let washroomId: String?
    let proposedData: ProposedWashroomData
}

struct ReportPayload: Encodable, Sendable {
    let washroomId: String
    let reason: String
    let detail: String?
}

final class SubmissionRepository {
    static let shared = SubmissionRepository()
    private let client = SupabaseClient.shared

    func submit(_ payload: SubmissionPayload) async throws {
        // TODO: POST to /rest/v1/submissions
        _ = payload
    }

    func report(_ payload: ReportPayload) async throws {
        // TODO: POST to /rest/v1/reports
        _ = payload
    }
}
