import SwiftUI
import SwiftData

struct DetailView: View {
    let washroomID: String
    @Environment(AppRouter.self) private var router
    @Query private var allWashrooms: [Washroom]

    private var washroom: Washroom? {
        allWashrooms.first { $0.id == washroomID }
    }

    var body: some View {
        Group {
            if let washroom {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        PhotoGallery(washroomID: washroomID)

                        VStack(alignment: .leading, spacing: Spacing.lg) {
                            // Header
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: Spacing.xs) {
                                    Text(washroom.name)
                                        .font(.looTitle)
                                    if let nameBn = washroom.nameBn {
                                        Text(nameBn)
                                            .font(.looBody)
                                            .foregroundStyle(Color.textSecondary)
                                    }
                                }
                                Spacer()
                                if let rating = washroom.averageRating {
                                    RatingPill(rating: rating, count: washroom.ratingCount)
                                }
                            }

                            // Inclusivity + freshness badges
                            HStack(spacing: Spacing.xs) {
                                WomenFriendlyBadge(gender: washroom.gender)
                                FreshnessBadge(freshness: washroom.freshness)
                            }

                            // Distance + opening status
                            HStack(spacing: Spacing.md) {
                                if let d = washroom.distanceMeters {
                                    Label(Formatting.distance(d), systemImage: "location.fill")
                                }
                                OpeningStatusLabel(washroom: washroom)
                            }
                            .font(.looCaption)
                            .foregroundStyle(Color.textSecondary)

                            // Action row
                            HStack(spacing: Spacing.sm) {
                                Button {
                                    router.navigate(to: .finder(washroomID: washroomID))
                                } label: {
                                    Label("Find", systemImage: "location.north.fill")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(Color.brand)

                                Button {
                                    openInMaps(washroom: washroom)
                                } label: {
                                    Label("Directions", systemImage: "map")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .tint(Color.brand)

                                // TODO: Report button
                            }

                            // Info grid
                            InfoGrid(washroom: washroom)

                            // TODO: Recent reviews section (Week 5)
                            // TODO: Suggest edit footer (Week 4)
                        }
                        .padding(Spacing.md)
                    }
                }
                .navigationTitle(washroom.name)
                .navigationBarTitleDisplayMode(.inline)
            } else {
                // Washroom not cached yet — fetch from remote
                ProgressView("Loading…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .task {
                        // TODO: WashroomRepository.shared.fetchDetail(id: washroomID)
                        //       then upsert into SwiftData
                    }
            }
        }
    }

    private func openInMaps(washroom: Washroom) {
        let coords = "\(washroom.latitude),\(washroom.longitude)"
        guard let url = URL(string: "maps://?ll=\(coords)&q=\(washroom.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else { return }
        // TODO: UIApplication.shared.open(url)
        _ = url
    }
}

// MARK: - Sub-views

private struct WomenFriendlyBadge: View {
    let gender: WashroomGender

    var body: some View {
        let friendly = gender.isWomenFriendly
        HStack(spacing: 6) {
            Image(systemName: friendly ? "checkmark.seal.fill" : "xmark.seal.fill")
            Text(friendly ? "Women Friendly" : "Men Only")
                .fontWeight(.semibold)
        }
        .font(.looCaption)
        .foregroundStyle(friendly ? Color.womenPink : Color.textSecondary)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(
            (friendly ? Color.womenPink : Color.textSecondary).opacity(0.12),
            in: Capsule()
        )
    }
}

private struct RatingPill: View {
    let rating: Double
    let count: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill").foregroundStyle(Color.accent)
            Text(Formatting.rating(rating)).fontWeight(.semibold)
            Text("(\(count))").foregroundStyle(Color.textSecondary)
        }
        .font(.looCaption)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(Color.accent.opacity(0.12), in: Capsule())
    }
}

private struct InfoGrid: View {
    let washroom: Washroom

    var body: some View {
        LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: Spacing.sm) {
            InfoCell(icon: washroom.gender.systemImage,
                     label: washroom.gender.displayName,
                     tint: washroom.gender.markerColor)
            InfoCell(icon: washroom.accessible ? "figure.roll" : "figure.walk",
                     label: washroom.accessible ? "Accessible" : "Standard",
                     tint: washroom.accessible ? .brand : .textSecondary)
            InfoCell(icon: "banknote", label: Formatting.fee(washroom.feeBdt),
                     tint: washroom.isFree ? .success : .warning)
            InfoCell(icon: washroom.type.systemImage,
                     label: washroom.type.displayName, tint: .brand)
            if let clean = washroom.cleanlinessRating {
                InfoCell(icon: "sparkles", label: String(format: "Clean %.1f", clean),
                         tint: clean >= 3.5 ? .success : (clean >= 2.5 ? .warning : .danger))
            }
            if washroom.babyChanging == true {
                InfoCell(icon: "figure.and.child.holdinghands",
                         label: "Baby changing", tint: .brand)
            }
            if washroom.menstrualProducts == true {
                InfoCell(icon: "heart.circle.fill",
                         label: "Menstrual products", tint: .womenPink)
            }
            if washroom.type == .mosque, washroom.wuduArea == true {
                InfoCell(icon: "drop.fill",
                         label: "Wudu area", tint: .brand)
            }
        }
    }
}

private struct FreshnessBadge: View {
    let freshness: WashroomFreshness

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: freshness.systemImage)
            Text(freshness.label).fontWeight(.semibold)
        }
        .font(.looCaption)
        .foregroundStyle(freshness.tint)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(freshness.tint.opacity(0.12), in: Capsule())
    }
}

private struct OpeningStatusLabel: View {
    let washroom: Washroom

    var body: some View {
        switch washroom.isOpen() {
        case .some(true):
            Label("Open now", systemImage: "clock.fill")
                .foregroundStyle(Color.success)
        case .some(false):
            Label("Closed", systemImage: "clock")
                .foregroundStyle(Color.warning)
        case .none:
            EmptyView()
        }
    }
}

private struct InfoCell: View {
    let icon: String
    let label: String
    let tint: Color

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(tint)
                .frame(width: 28)
            Text(label).font(.looBody)
        }
        .padding(Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.surfaceElev, in: RoundedRectangle(cornerRadius: Radius.card / 2))
    }
}
