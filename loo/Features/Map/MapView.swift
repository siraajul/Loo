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

    /// Washrooms sorted by distance from the user, closest first.
    private var nearbyWashrooms: [Washroom] {
        guard let userCoord = locationService.location?.coordinate else {
            return Array(washrooms.prefix(5))
        }
        return Array(
            washrooms
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
            // Top bar floats over the map; top padding = status bar + small gap
            .overlay(alignment: .top) {
                TopBar(
                    searchText:   $viewModel.searchText,
                    filterActive: !viewModel.filterOptions.isDefault,
                    onFilterTap:  { viewModel.isFilterSheetPresented = true },
                    onProfileTap: { router.navigate(to: .profile) }
                )
                .padding(.horizontal, Spacing.sm)
                .padding(.top, statusBarHeight + Spacing.xs)
                .padding(.bottom, Spacing.xs)
                .background {
                    Rectangle()
                        .fill(.regularMaterial)
                        .ignoresSafeArea(edges: .top)
                }
            }
            .safeAreaInset(edge: .bottom) {
                NearbySheet(washrooms: nearbyWashrooms)
            }
            .overlay(alignment: .bottomTrailing) {
                AddWashroomFAB { viewModel.isSubmitPresented = true }
                    .padding(.trailing, Spacing.md)
                    .padding(.bottom, 160)
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $viewModel.isSubmitPresented) {
                SubmitView(prefilledCoordinate: locationService.location?.coordinate)
            }
            .sheet(isPresented: $viewModel.isFilterSheetPresented) {
                FilterSheet(options: $viewModel.filterOptions)
            }
            .onAppear {
                SeedData.injectIfNeeded(into: modelContext)
                locationService.requestPermission()
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
                washrooms: washrooms,
                onWashroomTap: { router.navigate(to: .detail(washroomID: $0)) },
                userLocation: locationService.location?.coordinate
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

private struct TopBar: View {
    @Binding var searchText: String
    let filterActive: Bool
    let onFilterTap:  () -> Void
    let onProfileTap: () -> Void

    var body: some View {
        HStack(spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.textSecondary)
                TextField("Search washrooms…", text: $searchText)
                    .font(.looBody)
                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.textSecondary)
                    }
                }
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, 10)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Radius.button))

            Button(action: onFilterTap) {
                Image(systemName: filterActive
                      ? "line.3.horizontal.decrease.circle.fill"
                      : "line.3.horizontal.decrease.circle")
                    .font(.system(size: 22))
                    .foregroundStyle(filterActive ? Color.brand : Color.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(.regularMaterial, in: Circle())
            }

            Button(action: onProfileTap) {
                Image(systemName: "person.circle")
                    .font(.system(size: 22))
                    .foregroundStyle(Color.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(.regularMaterial, in: Circle())
            }
        }
    }
}
