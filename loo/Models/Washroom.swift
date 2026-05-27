import Foundation
import SwiftData
import CoreLocation
import SwiftUI

enum WashroomType: String, Codable, CaseIterable, Sendable {
    case publicToilet = "public"
    case mosque, mall, restaurant
    case petrolPump   = "petrol_pump"
    case hospital, other

    var displayName: String {
        switch self {
        case .publicToilet: "Public"
        case .mosque:       "Mosque"
        case .mall:         "Mall"
        case .restaurant:   "Restaurant"
        case .petrolPump:   "Petrol Pump"
        case .hospital:     "Hospital"
        case .other:        "Other"
        }
    }

    var systemImage: String {
        switch self {
        case .publicToilet: "figure.walk"
        case .mosque:       "building.columns"
        case .mall:         "bag"
        case .restaurant:   "fork.knife"
        case .petrolPump:   "fuelpump"
        case .hospital:     "cross.fill"
        case .other:        "mappin"
        }
    }
}

enum WashroomGender: String, Codable, CaseIterable, Sendable {
    case male, female, both, family

    var displayName: String {
        switch self {
        case .male:   "Male"
        case .female: "Female"
        case .both:   "Both"
        case .family: "Family"
        }
    }

    var systemImage: String {
        switch self {
        case .male:   "figure.stand"
        case .female: "figure.dress"
        case .both:   "person.2"
        case .family: "figure.2.and.child.holdinghands"
        }
    }

    /// Marker color — pink for female-only, blue for male-only, brand green otherwise.
    var markerColor: Color {
        switch self {
        case .female: return .womenPink
        case .male:   return .menBlue
        case .both, .family: return .brand
        }
    }
}

@Model
final class Washroom {
    @Attribute(.unique) var id: String
    var name: String
    var nameBn: String?
    var typeRaw: String
    var genderRaw: String
    var accessible: Bool
    var bidet: Bool
    var hasSoap: Bool?
    var hasTissue: Bool?
    var feeBdt: Int
    var latitude: Double
    var longitude: Double
    var notes: String?
    var status: String
    var averageRating: Double?
    var ratingCount: Int
    var distanceMeters: Double?
    var createdAt: Date
    var updatedAt: Date
    var cachedAt: Date

    var type: WashroomType   { WashroomType(rawValue: typeRaw)   ?? .other }
    var gender: WashroomGender { WashroomGender(rawValue: genderRaw) ?? .both }
    var coordinate: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
    var isFree: Bool { feeBdt == 0 }

    init(
        id: String,
        name: String,
        nameBn: String? = nil,
        type: WashroomType = .publicToilet,
        gender: WashroomGender = .both,
        accessible: Bool = false,
        bidet: Bool = true,
        hasSoap: Bool? = nil,
        hasTissue: Bool? = nil,
        feeBdt: Int = 0,
        latitude: Double,
        longitude: Double,
        notes: String? = nil,
        status: String = "active",
        averageRating: Double? = nil,
        ratingCount: Int = 0,
        distanceMeters: Double? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id             = id
        self.name           = name
        self.nameBn         = nameBn
        self.typeRaw        = type.rawValue
        self.genderRaw      = gender.rawValue
        self.accessible     = accessible
        self.bidet          = bidet
        self.hasSoap        = hasSoap
        self.hasTissue      = hasTissue
        self.feeBdt         = feeBdt
        self.latitude       = latitude
        self.longitude      = longitude
        self.notes          = notes
        self.status         = status
        self.averageRating  = averageRating
        self.ratingCount    = ratingCount
        self.distanceMeters = distanceMeters
        self.createdAt      = createdAt
        self.updatedAt      = updatedAt
        self.cachedAt       = .now
    }
}
