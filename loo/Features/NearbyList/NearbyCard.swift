import SwiftUI

struct NearbyCard: View {
    let washroom: Washroom
    @Environment(AppRouter.self) private var router

    var body: some View {
        Button {
            router.navigate(to: .detail(washroomID: washroom.id))
        } label: {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(washroom.gender.markerColor.opacity(0.12))
                    Image(systemName: washroom.type.systemImage)
                        .font(.system(size: 22))
                        .foregroundStyle(washroom.gender.markerColor)
                }
                .frame(width: 44, height: 44)
                .overlay(alignment: .topTrailing) {
                    if washroom.gender != .both {
                        Image(systemName: washroom.gender.systemImage)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(washroom.gender.markerColor)
                            .padding(2)
                            .background(Color.surface, in: Circle())
                            .offset(x: 4, y: -4)
                    }
                }

                Text(washroom.name)
                    .font(.looCaption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(2)
                    .frame(width: 100, alignment: .leading)

                HStack(spacing: 2) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 10))
                    if let d = washroom.distanceMeters {
                        Text(Formatting.distance(d))
                            .font(.looCaption)
                    }
                }
                .foregroundStyle(Color.textSecondary)

                if washroom.isFree {
                    Text("Free")
                        .font(.looCaption)
                        .foregroundStyle(Color.success)
                }
            }
            .padding(Spacing.sm)
            .frame(width: 120)
            .background(Color.surfaceElev, in: RoundedRectangle(cornerRadius: Radius.card))
        }
        .buttonStyle(.plain)
    }
}
