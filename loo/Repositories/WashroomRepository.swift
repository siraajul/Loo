import Foundation
import CoreLocation

// Network DTO — pure value type so Codable/Sendable conformances are non-isolated.
struct WashroomDTO: Codable, Sendable {
    let id: String
    let name: String
    let nameBn: String?
    let type: String
    let gender: String
    let accessible: Bool
    let feeBdt: Int
    let distanceM: Double
    let lat: Double
    let lng: Double
    let averageRating: Double?
    let ratingCount: Int?
}

// Conversion to SwiftData model must happen on @MainActor (model context lives there).
extension WashroomDTO {
    @MainActor
    func toModel() -> Washroom {
        Washroom(
            id:             id,
            name:           name,
            nameBn:         nameBn,
            type:           WashroomType(rawValue: type)     ?? .other,
            gender:         WashroomGender(rawValue: gender) ?? .both,
            accessible:     accessible,
            feeBdt:         feeBdt,
            latitude:       lat,
            longitude:      lng,
            averageRating:  averageRating,
            ratingCount:    ratingCount ?? 0,
            distanceMeters: distanceM
        )
    }
}

struct NearbyParams: Encodable {
    let lat: Double
    let lng: Double
    let radiusM: Int
    let maxResults: Int
}

final class WashroomRepository {
    static let shared = WashroomRepository()
    private let client = SupabaseClient.shared

    func fetchNearby(
        coordinate: CLLocationCoordinate2D,
        radiusMeters: Int = 2000,
        maxResults: Int = 50
    ) async throws -> [WashroomDTO] {
        let params = NearbyParams(
            lat:        coordinate.latitude,
            lng:        coordinate.longitude,
            radiusM:    radiusMeters,
            maxResults: maxResults
        )
        let body = try JSONEncoder.supabase.encode(params)
        let data = try await client.rpc(functionName: "nearby_washrooms", body: body)
        return try JSONDecoder.supabase.decode([WashroomDTO].self, from: data)
    }

    func fetchDetail(id: String) async throws -> WashroomDTO {
        // TODO: GET /rest/v1/washrooms?id=eq.<id>&select=*
        throw URLError(.unsupportedURL)
    }
}
