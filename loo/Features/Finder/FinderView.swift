import SwiftUI
import SwiftData
import CoreLocation
import UIKit

struct FinderView: View {
    let washroomID: String
    @Environment(LocationService.self) private var locationService
    @Environment(\.dismiss)            private var dismiss
    @Query private var allWashrooms: [Washroom]
    @State private var viewModel = FinderViewModel()

    private var washroom: Washroom? {
        allWashrooms.first { $0.id == washroomID }
    }

    var body: some View {
        Group {
            if let washroom {
                finderContent(washroom: washroom)
            } else {
                Color.brand.ignoresSafeArea()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(Spacing.sm)
                        .background(.ultraThinMaterial, in: Circle())
                }
            }
        }
    }

    @ViewBuilder
    private func finderContent(washroom: Washroom) -> some View {
        ZStack {
            // Background: red when far, amber when close, green when arrived
            LinearGradient(
                colors: viewModel.gradientColors,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.0), value: viewModel.gradientColors.first)

            VStack(spacing: 0) {
                // Place name
                Text(washroom.name)
                    .font(.looHeadline)
                    .foregroundStyle(.white)
                    .padding(.top, 80)
                    .padding(.horizontal, Spacing.lg)
                    .multilineTextAlignment(.center)

                if let nameBn = washroom.nameBn {
                    Text(nameBn)
                        .font(.looBody)
                        .foregroundStyle(.white.opacity(0.75))
                        .padding(.top, Spacing.xs)
                }

                Spacer()

                // Compass arrow
                ArrowView(rotation: viewModel.arrowRotation)

                // Distance counter
                Text(Formatting.distance(viewModel.distanceMeters))
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.4, dampingFraction: 0.7),
                               value: viewModel.distanceMeters)
                    .padding(.top, Spacing.lg)

                Text("away")
                    .font(.looBody)
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.top, Spacing.xs)

                Spacer()

                // Info chips row
                HStack(spacing: Spacing.sm) {
                    InfoChip(icon: washroom.type.systemImage,   label: washroom.type.displayName)
                    InfoChip(icon: "banknote",                  label: Formatting.fee(washroom.feeBdt))
                    if washroom.accessible {
                        InfoChip(icon: "figure.roll", label: "Accessible")
                    }
                }
                .padding(.bottom, Spacing.lg)

                // Open in Maps
                Button { openInMaps(washroom: washroom) } label: {
                    Label("Open in Maps", systemImage: "map")
                        .font(.looBody.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, Spacing.md)
                        .background(.ultraThinMaterial, in: Capsule())
                }
                .padding(.bottom, 48)
            }

            // Calibration overlay
            if viewModel.needsCalibration {
                CalibrationOverlay()
            }
        }
        .statusBarHidden()
        .onAppear  { viewModel.start(targeting: washroom, locationService: locationService) }
        .onDisappear { viewModel.stop() }
    }

    private func openInMaps(washroom: Washroom) {
        let coords = "\(washroom.latitude),\(washroom.longitude)"
        let name   = washroom.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "maps://?ll=\(coords)&q=\(name)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Sub-views

private struct InfoChip: View {
    let icon: String
    let label: String

    var body: some View {
        Label(label, systemImage: icon)
            .font(.looCaption.weight(.medium))
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: Capsule())
    }
}

private struct CalibrationOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()
            VStack(spacing: Spacing.md) {
                Image(systemName: "figure.wave")
                    .font(.system(size: 52))
                    .foregroundStyle(.white)
                Text("Wave your phone in a figure-8 to calibrate the compass.")
                    .font(.looBody)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
            }
        }
    }
}
