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
    case male, female, both, family, hijra

    var displayName: String {
        switch self {
        case .male:   "Male"
        case .female: "Female"
        case .both:   "Mixed"
        case .family: "Family"
        case .hijra:  "Hijra"
        }
    }

    var systemImage: String {
        switch self {
        case .male:   "figure.stand"
        case .female: "figure.dress"
        case .both:   "person.2"
        case .family: "figure.2.and.child.holdinghands"
        case .hijra:  "figure.stand.dress.line.vertical.figure"
        }
    }

    /// Marker color — pink for female-only, blue for male-only, purple for hijra, brand green otherwise.
    var markerColor: Color {
        switch self {
        case .female: return .womenPink
        case .male:   return .menBlue
        case .hijra:  return .hijraPurple
        case .both, .family: return .brand
        }
    }

    /// True if women can use this washroom. Hijra-designated spaces are excluded —
    /// they are a separate third-gender space, not a women's space.
    var isWomenFriendly: Bool {
        switch self {
        case .female, .both, .family: return true
        case .male, .hijra: return false
        }
    }
}

/// Freshness of the "last verified by a community member" signal on a washroom.
enum WashroomFreshness: Sendable {
    case fresh       // verified within the last week
    case aging       // verified within the last month
    case stale       // verified more than a month ago
    case unverified  // never community-confirmed

    var label: String {
        switch self {
        case .fresh:      "Verified recently"
        case .aging:      "Verified this month"
        case .stale:      "Verification old"
        case .unverified: "Unverified"
        }
    }

    var systemImage: String {
        switch self {
        case .fresh:      "checkmark.seal.fill"
        case .aging:      "checkmark.seal"
        case .stale:      "clock.badge.exclamationmark"
        case .unverified: "questionmark.circle"
        }
    }

    var tint: Color {
        switch self {
        case .fresh:      .success
        case .aging:      .brand
        case .stale:      .warning
        case .unverified: .textSecondary
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

    // Local-fit extensions
    /// Wudu (ritual ablution) area available — meaningful for mosques.
    var wuduArea: Bool?
    /// Baby changing station available.
    var babyChanging: Bool?
    /// Menstrual hygiene products available (free or vending).
    var menstrualProducts: Bool?
    /// Cleanliness sub-rating (0–5), separate from overall rating.
    var cleanlinessRating: Double?
    /// When a community member last confirmed this listing was accurate.
    var lastVerifiedAt: Date?
    /// Opening hours: "24/7" or "HH:mm-HH:mm" (24-hour, single window per day).
    var openingHoursRaw: String?

    var type: WashroomType   { WashroomType(rawValue: typeRaw)   ?? .other }
    var gender: WashroomGender { WashroomGender(rawValue: genderRaw) ?? .both }
    var coordinate: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
    var isFree: Bool { feeBdt == 0 }

    /// Whether the washroom is open at `referenceDate`. Returns `nil` if hours are unknown
    /// or unparseable, so callers can distinguish "closed" from "unknown".
    func isOpen(at referenceDate: Date = .now) -> Bool? {
        guard let raw = openingHoursRaw?.trimmingCharacters(in: .whitespaces), !raw.isEmpty else { return nil }
        if raw == "24/7" { return true }
        let parts = raw.split(separator: "-")
        guard parts.count == 2,
              let openMin  = Self.minutesSinceMidnight(parts[0]),
              let closeMin = Self.minutesSinceMidnight(parts[1]) else { return nil }
        let now = Calendar.current.dateComponents([.hour, .minute], from: referenceDate)
        let nowMin = (now.hour ?? 0) * 60 + (now.minute ?? 0)
        if openMin <= closeMin {
            return nowMin >= openMin && nowMin < closeMin
        } else {
            // Window crosses midnight, e.g. 22:00-02:00
            return nowMin >= openMin || nowMin < closeMin
        }
    }

    private static func minutesSinceMidnight(_ hhmm: Substring) -> Int? {
        let bits = hhmm.split(separator: ":")
        guard bits.count == 2, let h = Int(bits[0]), let m = Int(bits[1]) else { return nil }
        return h * 60 + m
    }

    var freshness: WashroomFreshness {
        guard let date = lastVerifiedAt else { return .unverified }
        let days = Calendar.current.dateComponents([.day], from: date, to: .now).day ?? .max
        if days <= 7  { return .fresh }
        if days <= 30 { return .aging }
        return .stale
    }

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
        wuduArea: Bool? = nil,
        babyChanging: Bool? = nil,
        menstrualProducts: Bool? = nil,
        cleanlinessRating: Double? = nil,
        lastVerifiedAt: Date? = nil,
        openingHoursRaw: String? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id                 = id
        self.name               = name
        self.nameBn             = nameBn
        self.typeRaw            = type.rawValue
        self.genderRaw          = gender.rawValue
        self.accessible         = accessible
        self.bidet              = bidet
        self.hasSoap            = hasSoap
        self.hasTissue          = hasTissue
        self.feeBdt             = feeBdt
        self.latitude           = latitude
        self.longitude          = longitude
        self.notes              = notes
        self.status             = status
        self.averageRating      = averageRating
        self.ratingCount        = ratingCount
        self.distanceMeters     = distanceMeters
        self.wuduArea           = wuduArea
        self.babyChanging       = babyChanging
        self.menstrualProducts  = menstrualProducts
        self.cleanlinessRating  = cleanlinessRating
        self.lastVerifiedAt     = lastVerifiedAt
        self.openingHoursRaw    = openingHoursRaw
        self.createdAt          = createdAt
        self.updatedAt          = updatedAt
        self.cachedAt           = .now
    }
}
