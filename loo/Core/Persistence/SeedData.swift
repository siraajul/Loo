import SwiftData
import Foundation

// Injects mock washrooms on first launch so the app is usable before the backend is wired up.
// Remove or gate behind a debug flag once real Supabase data is flowing.
enum SeedData {
    private static func daysAgo(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -n, to: .now) ?? .now
    }

    static let washrooms: [Washroom] = [
        Washroom(id: "seed-1",  name: "Bashundhara City Mall",        nameBn: "বসুন্ধরা সিটি",
                 type: .mall,       gender: .both,  accessible: true,  feeBdt: 0,
                 latitude: 23.7506, longitude: 90.3930,
                 averageRating: 4.2, ratingCount: 38,
                 babyChanging: true, menstrualProducts: true, cleanlinessRating: 4.3,
                 lastVerifiedAt: daysAgo(3),  openingHoursRaw: "10:00-22:00"),

        Washroom(id: "seed-2",  name: "Gulshan-1 DCC Market",         nameBn: "গুলশান-১ ডিসিসি",
                 type: .publicToilet, gender: .both, accessible: false, feeBdt: 5,
                 latitude: 23.7826, longitude: 90.4143,
                 averageRating: 2.8, ratingCount: 14,
                 cleanlinessRating: 2.5,
                 lastVerifiedAt: daysAgo(12), openingHoursRaw: "06:00-22:00"),

        Washroom(id: "seed-3",  name: "Jamuna Future Park",           nameBn: "যমুনা ফিউচার পার্ক",
                 type: .mall,       gender: .both,  accessible: true,  feeBdt: 0,
                 latitude: 23.8131, longitude: 90.4248,
                 averageRating: 4.5, ratingCount: 72,
                 babyChanging: true, menstrualProducts: true, cleanlinessRating: 4.6,
                 lastVerifiedAt: daysAgo(1),  openingHoursRaw: "10:00-22:00"),

        Washroom(id: "seed-4",  name: "Baitul Mukarram Mosque",       nameBn: "বায়তুল মোকাররম",
                 type: .mosque,     gender: .male,  accessible: false, feeBdt: 0,
                 latitude: 23.7264, longitude: 90.4089,
                 averageRating: 3.9, ratingCount: 27,
                 wuduArea: true, cleanlinessRating: 3.7,
                 lastVerifiedAt: daysAgo(6),  openingHoursRaw: "04:30-22:30"),

        Washroom(id: "seed-5",  name: "Dhanmondi Lake Park",
                 type: .publicToilet, gender: .both, accessible: false, feeBdt: 2,
                 latitude: 23.7461, longitude: 90.3742,
                 averageRating: 3.1, ratingCount: 9,
                 cleanlinessRating: 2.9,
                 lastVerifiedAt: daysAgo(45), openingHoursRaw: "06:00-21:00"),

        Washroom(id: "seed-6",  name: "Panthapath Petrol Pump",
                 type: .petrolPump, gender: .both,  accessible: false, feeBdt: 0,
                 latitude: 23.7527, longitude: 90.3882,
                 averageRating: 2.5, ratingCount: 6,
                 cleanlinessRating: 2.3,
                 lastVerifiedAt: daysAgo(20), openingHoursRaw: "24/7"),

        Washroom(id: "seed-7",  name: "Square Hospital",              nameBn: "স্কয়ার হাসপাতাল",
                 type: .hospital,   gender: .both,  accessible: true,  feeBdt: 0,
                 latitude: 23.7477, longitude: 90.3780,
                 averageRating: 4.0, ratingCount: 19,
                 babyChanging: true, cleanlinessRating: 4.1,
                 lastVerifiedAt: daysAgo(4),  openingHoursRaw: "24/7"),

        Washroom(id: "seed-8",  name: "Star Kabab Restaurant",
                 type: .restaurant, gender: .both,  accessible: false, feeBdt: 0,
                 latitude: 23.7493, longitude: 90.3878,
                 averageRating: 3.5, ratingCount: 11,
                 cleanlinessRating: 3.4,
                 lastVerifiedAt: daysAgo(9),  openingHoursRaw: "07:00-02:00"),

        Washroom(id: "seed-9",  name: "Motijheel Shapla Chatter",     nameBn: "মতিঝিল শাপলা চত্বর",
                 type: .publicToilet, gender: .male, accessible: false, feeBdt: 3,
                 latitude: 23.7281, longitude: 90.4205,
                 averageRating: 2.2, ratingCount: 5,
                 cleanlinessRating: 2.1,
                 lastVerifiedAt: daysAgo(60), openingHoursRaw: "06:00-22:00"),

        Washroom(id: "seed-10", name: "Uttara Sector-3 Park",
                 type: .publicToilet, gender: .both, accessible: false, feeBdt: 0,
                 latitude: 23.8726, longitude: 90.3940,
                 averageRating: 3.3, ratingCount: 8,
                 cleanlinessRating: 3.0,
                 openingHoursRaw: "06:00-21:00"),

        Washroom(id: "seed-11", name: "Banani DCC Trans-Inclusive Stop",
                 type: .publicToilet, gender: .hijra, accessible: true, feeBdt: 0,
                 latitude: 23.7937, longitude: 90.4066,
                 notes: "Hijra-inclusive third-gender washroom, run with Bandhu Social Welfare Society.",
                 averageRating: 3.8, ratingCount: 4,
                 cleanlinessRating: 3.6,
                 lastVerifiedAt: daysAgo(2),  openingHoursRaw: "07:00-21:00"),

        Washroom(id: "seed-12", name: "Lalbagh Fort Family Restroom", nameBn: "লালবাগ কেল্লা",
                 type: .publicToilet, gender: .family, accessible: true, feeBdt: 10,
                 latitude: 23.7186, longitude: 90.3884,
                 averageRating: 3.6, ratingCount: 22,
                 babyChanging: true, menstrualProducts: false, cleanlinessRating: 3.5,
                 lastVerifiedAt: daysAgo(5),  openingHoursRaw: "09:00-18:00"),
    ]

    @MainActor
    static func injectIfNeeded(into context: ModelContext) {
        // Insert any seed whose ID isn't already in the local store. This lets new seeds
        // appear on subsequent launches without wiping the app.
        let existingIDs: Set<String> = (try? context.fetch(FetchDescriptor<Washroom>()))
            .map { Set($0.map(\.id)) } ?? []
        var inserted = 0
        for w in washrooms where !existingIDs.contains(w.id) {
            context.insert(w)
            inserted += 1
        }
        if inserted > 0 { try? context.save() }
    }
}
