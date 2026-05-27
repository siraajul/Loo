import SwiftUI

struct FilterOptions: Equatable {
    var genderFilter: WashroomGender? = nil
    var accessibleOnly = false
    var freeOnly       = false
    var openNow        = false
    var minRating      = 0.0

    var isDefault: Bool {
        self == FilterOptions()
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

                Section("Accessibility & Cost") {
                    Toggle("Accessible only", isOn: $options.accessibleOnly)
                    Toggle("Free only",        isOn: $options.freeOnly)
                }

                Section("Hours") {
                    Toggle("Open now", isOn: $options.openNow)
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
