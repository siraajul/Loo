import SwiftUI
import SwiftData

// Root wrapper — exists so you can see a live preview in the Xcode canvas.
// looApp.swift uses MapView directly; this file is preview-only.
struct ContentView: View {
    var body: some View {
        MapView()
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Washroom.self, Rating.self, Submission.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    // Pre-populate preview with seed washrooms
    let ctx = container.mainContext
    SeedData.injectIfNeeded(into: ctx)

    return ContentView()
        .modelContainer(container)
        .environment(AppRouter())
        .environment(LocationService())
}
