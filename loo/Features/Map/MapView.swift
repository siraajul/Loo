import SwiftUI
import SwiftData
import UIKit
import CoreLocation

struct MapView: View {
    @Environment(AppRouter.self)       private var router
    @Environment(LocationService.self) private var locationService
    @Environment(\.modelContext)       private var modelContext
    @Query(filter: #Predicate<Washroom> { $0.status == "active" })
    private var washrooms: [Washroom]
    @State private var viewModel = MapViewModel()

    /// Washrooms passed through the current filter options and search text.
    private var filteredWashrooms: [Washroom] {
        let afterFilters = viewModel.filterOptions.apply(to: washrooms)
        let query = viewModel.searchText.trimmingCharacters(in: .whitespaces).lowercased()
        guard !query.isEmpty else { return afterFilters }
        return afterFilters.filter { w in
            w.name.lowercased().contains(query) ||
            (w.nameBn?.lowercased().contains(query) ?? false)
        }
    }

    /// Filtered washrooms sorted by distance from the user, closest first.
    private var nearbyWashrooms: [Washroom] {
        let pool = filteredWashrooms
        guard let userCoord = locationService.location?.coordinate else {
            return Array(pool.prefix(5))
        }
        return Array(
            pool
                .sorted { Geo.distance(from: userCoord, to: $0.coordinate)
                        < Geo.distance(from: userCoord, to: $1.coordinate) }
                .prefix(5)
        )
    }

    // Reads current status-bar height from UIKit so the top bar never overlaps time/battery
    private var statusBarHeight: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })?
            .windows.first(where: { $0.isKeyWindow })?
            .safeAreaInsets.top ?? 44
    }

    var body: some View {
        mapLayer
            .ignoresSafeArea()
            // Top bar floats over the map as Liquid Glass pills
            .overlay(alignment: .top) {
                TopBar(
                    searchText:   $viewModel.searchText,
                    filterActive: !viewModel.filterOptions.isDefault,
                    onFilterTap:  { viewModel.isFilterSheetPresented = true },
                    onProfileTap: { router.navigate(to: .profile) }
                )
                .padding(.horizontal, Spacing.md)
                .padding(.top, statusBarHeight + Spacing.xs)
            }
            .safeAreaInset(edge: .bottom) {
                NearbySheet(washrooms: nearbyWashrooms)
            }
            .overlay(alignment: .bottomTrailing) {
                VStack(spacing: Spacing.sm) {
                    LocateMeFAB {
                        guard locationService.location != nil else {
                            locationService.requestPermission()
                            return
                        }
                        viewModel.recenterTrigger = UUID()
                    }
                    AddWashroomFAB { viewModel.isSubmitPresented = true }
                }
                .padding(.trailing, Spacing.md)
                .padding(.bottom, 160)
            }
            .toolbar(.hidden, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $viewModel.isSubmitPresented) {
                SubmitView(prefilledCoordinate: locationService.location?.coordinate)
            }
            .sheet(isPresented: $viewModel.isFilterSheetPresented) {
                FilterSheet(options: $viewModel.filterOptions)
            }
            .onAppear {
                SeedData.injectIfNeeded(into: modelContext)
                // Onboarding requests permission with context. Only re-prompt if the user
                // skipped onboarding without granting, so we don't pop the system dialog cold.
                if locationService.authorizationStatus == .notDetermined {
                    locationService.requestPermission()
                }
            }
            .onChange(of: locationService.location) { _, loc in
                guard let coord = loc?.coordinate else { return }
                for washroom in washrooms {
                    washroom.distanceMeters = Geo.distance(from: coord, to: washroom.coordinate)
                }
            }
    }

    // OSMMapView is swapped for a plain rectangle in Xcode Previews because
    // MapLibre's Metal renderer cannot initialise without a real GPU context.
    @ViewBuilder
    private var mapLayer: some View {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            Rectangle().fill(Color(UIColor.secondarySystemBackground))
        } else {
            OSMMapView(
                washrooms: filteredWashrooms,
                onWashroomTap: { router.navigate(to: .detail(washroomID: $0)) },
                userLocation: locationService.location?.coordinate,
                recenterToken: viewModel.recenterTrigger
            )
        }
    }
}

// MARK: - Sub-views

private struct AddWashroomFAB: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Color.brand, in: Circle())
                .shadow(color: .brand.opacity(0.4), radius: 8, y: 4)
        }
    }
}

private struct LocateMeFAB: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "location.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.brand)
                .frame(width: 48, height: 48)
        }
        .glassEffect(.regular.interactive(), in: .circle)
    }
}

private struct TopBar: View {
    @Binding var searchText: String
    let filterActive: Bool
    let onFilterTap:  () -> Void
    let onProfileTap: () -> Void

    var body: some View {
        GlassEffectContainer(spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.textSecondary)
                    TextField("Search washrooms…", text: $searchText)
                        .font(.looBody)
                        .textFieldStyle(.plain)
                    if !searchText.isEmpty {
                        Button { searchText = "" } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color.textSecondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, 12)
                .glassEffect(.regular.interactive(), in: .capsule)

                Button(action: onFilterTap) {
                    Image(systemName: filterActive
                          ? "line.3.horizontal.decrease"
                          : "line.3.horizontal.decrease")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(filterActive ? Color.white : Color.textPrimary)
                        .frame(width: 44, height: 44)
                }
                .glassEffect(
                    filterActive
                        ? .regular.tint(Color.brand).interactive()
                        : .regular.interactive(),
                    in: .circle
                )

                Button(action: onProfileTap) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)
                        .frame(width: 44, height: 44)
                }
                .glassEffect(.regular.interactive(), in: .circle)
            }
        }
    }
}
