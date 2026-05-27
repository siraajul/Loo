import SwiftData
import Foundation

// Injects mock washrooms on first launch so the app is usable before the backend is wired up.
// Remove or gate behind a debug flag once real Supabase data is flowing.
enum SeedData {
    static let washrooms: [Washroom] = [
        Washroom(id: "seed-1",  name: "Bashundhara City Mall",        nameBn: "বসুন্ধরা সিটি",
                 type: .mall,       gender: .both,  accessible: true,  feeBdt: 0,
                 latitude: 23.7506, longitude: 90.3930,
                 averageRating: 4.2, ratingCount: 38, distanceMeters: 320),

        Washroom(id: "seed-2",  name: "Gulshan-1 DCC Market",         nameBn: "গুলশান-১ ডিসিসি",
                 type: .publicToilet, gender: .both, accessible: false, feeBdt: 5,
                 latitude: 23.7826, longitude: 90.4143,
                 averageRating: 2.8, ratingCount: 14, distanceMeters: 650),

        Washroom(id: "seed-3",  name: "Jamuna Future Park",           nameBn: "যমুনা ফিউচার পার্ক",
                 type: .mall,       gender: .both,  accessible: true,  feeBdt: 0,
                 latitude: 23.8131, longitude: 90.4248,
                 averageRating: 4.5, ratingCount: 72, distanceMeters: 1200),

        Washroom(id: "seed-4",  name: "Baitul Mukarram Mosque",       nameBn: "বায়তুল মোকাররম",
                 type: .mosque,     gender: .male,  accessible: false, feeBdt: 0,
                 latitude: 23.7264, longitude: 90.4089,
                 averageRating: 3.9, ratingCount: 27, distanceMeters: 890),

        Washroom(id: "seed-5",  name: "Dhanmondi Lake Park",
                 type: .publicToilet, gender: .both, accessible: false, feeBdt: 2,
                 latitude: 23.7461, longitude: 90.3742,
                 averageRating: 3.1, ratingCount: 9,  distanceMeters: 1500),

        Washroom(id: "seed-6",  name: "Panthapath Petrol Pump",
                 type: .petrolPump, gender: .both,  accessible: false, feeBdt: 0,
                 latitude: 23.7527, longitude: 90.3882,
                 averageRating: 2.5, ratingCount: 6,  distanceMeters: 430),

        Washroom(id: "seed-7",  name: "Square Hospital",              nameBn: "স্কয়ার হাসপাতাল",
                 type: .hospital,   gender: .both,  accessible: true,  feeBdt: 0,
                 latitude: 23.7477, longitude: 90.3780,
                 averageRating: 4.0, ratingCount: 19, distanceMeters: 760),

        Washroom(id: "seed-8",  name: "Star Kabab Restaurant",
                 type: .restaurant, gender: .both,  accessible: false, feeBdt: 0,
                 latitude: 23.7893, longitude: 90.4067,
                 averageRating: 3.5, ratingCount: 11, distanceMeters: 980),

        Washroom(id: "seed-9",  name: "Motijheel Shapla Chatter",     nameBn: "মতিঝিল শাপলা চত্বর",
                 type: .publicToilet, gender: .male, accessible: false, feeBdt: 3,
                 latitude: 23.7281, longitude: 90.4205,
                 averageRating: 2.2, ratingCount: 5,  distanceMeters: 2100),

        Washroom(id: "seed-10", name: "Uttara Sector-3 Park",
                 type: .publicToilet, gender: .both, accessible: false, feeBdt: 0,
                 latitude: 23.8726, longitude: 90.3940,
                 averageRating: 3.3, ratingCount: 8,  distanceMeters: 3400),
    ]

    @MainActor
    static func injectIfNeeded(into context: ModelContext) {
        let descriptor = FetchDescriptor<Washroom>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }
        washrooms.forEach { context.insert($0) }
        try? context.save()
    }
}
