import Foundation

enum Formatting {
    static func distance(_ meters: Double) -> String {
        meters < 1000
            ? "\(Int(meters))m"
            : String(format: "%.1fkm", meters / 1000)
    }

    static func fee(_ bdt: Int) -> String {
        bdt == 0 ? "Free" : "৳\(bdt)"
    }

    static func rating(_ value: Double?) -> String {
        guard let value else { return "No ratings" }
        return String(format: "%.1f", value)
    }
}
