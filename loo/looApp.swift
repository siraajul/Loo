import SwiftUI
import SwiftData
import CoreLocation

@main
struct looApp: App {
    @State private var router          = AppRouter()
    @State private var locationService = LocationService()

    var sharedModelContainer: ModelContainer = {
        do {
            return try AppPersistence.makeContainer()
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: Bindable(router).path) {
                MapView()
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .detail(let id):
                            DetailView(washroomID: id)
                        case .finder(let id):
                            FinderView(washroomID: id)
                        case .submit:
                            SubmitView(prefilledCoordinate: locationService.location?.coordinate)
                        case .editSubmission(let id):
                            // TODO: Prefill SubmitView with existing washroom data (Week 4)
                            SubmitView(prefilledCoordinate: nil)
                                .onAppear { _ = id }
                        case .profile:
                            ProfileView()
                        }
                    }
            }
            .environment(router)
            .environment(locationService)
            .sheet(isPresented: $router.isAuthPresented) {
                SignInView()
                    .environment(router)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
