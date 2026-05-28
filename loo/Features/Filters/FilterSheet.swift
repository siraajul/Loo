import SwiftUI

struct FilterOptions: Equatable {
    var genderFilter: WashroomGender? = nil
    var womenFriendlyOnly  = false
    var accessibleOnly     = false
    var freeOnly           = false
    var openNow            = false
    var babyChangingOnly   = false
    var menstrualProductsOnly = false
    var wuduAreaOnly       = false
    var minRating          = 0.0

    var isDefault: Bool {
        self == FilterOptions()
    }

    /// Apply the options to a list of washrooms. Pure function — testable, side-effect free.
    func apply(to washrooms: [Washroom], now: Date = .now) -> [Washroom] {
        washrooms.filter { w in
            if let g = genderFilter, w.gender != g { return false }
            if womenFriendlyOnly,    !w.gender.isWomenFriendly { return false }
            if accessibleOnly,       !w.accessible             { return false }
            if freeOnly,             !w.isFree                 { return false }
            if babyChangingOnly,     w.babyChanging != true    { return false }
            if menstrualProductsOnly, w.menstrualProducts != true { return false }
            if wuduAreaOnly,         w.wuduArea != true        { return false }
            if openNow, w.isOpen(at: now) != true              { return false }
            if minRating > 0, (w.averageRating ?? 0) < minRating { return false }
            return true
        }
    }
}

struct FilterSheet: View {
    @Binding var options: FilterOptions
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Gender") {
                    Picker("Gender", selection: $options.genderFilter) {
                        Text("Any").tag(WashroomGender?.none)
                        ForEach(WashroomGender.allCases, id: \.self) { g in
                            Text(g.displayName).tag(Optional(g))
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Inclusivity") {
                    Toggle("Women friendly only", isOn: $options.womenFriendlyOnly)
                }

                Section("Accessibility & Cost") {
                    Toggle("Accessible only", isOn: $options.accessibleOnly)
                    Toggle("Free only",        isOn: $options.freeOnly)
                }

                Section("Hours") {
                    Toggle("Open now", isOn: $options.openNow)
                }

                Section("Amenities") {
                    Toggle("Baby changing",        isOn: $options.babyChangingOnly)
                    Toggle("Menstrual products",   isOn: $options.menstrualProductsOnly)
                    Toggle("Wudu area (mosques)",  isOn: $options.wuduAreaOnly)
                }

                Section("Minimum Rating") {
                    HStack {
                        Image(systemName: "star.fill").foregroundStyle(Color.accent)
                        Slider(value: $options.minRating, in: 0...5, step: 0.5)
                        Text(options.minRating == 0 ? "Any" : String(format: "%.1f+", options.minRating))
                            .frame(width: 44)
                            .font(.looCaption)
                    }
                }

                if !options.isDefault {
                    Section {
                        Button("Reset Filters", role: .destructive) {
                            options = FilterOptions()
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.tint(Color.brand)
                }
            }
        }
    }
}
