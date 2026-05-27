import SwiftUI

struct NearbySheet: View {
    let washrooms: [Washroom]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Drag handle
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 5)
                .frame(maxWidth: .infinity)
                .padding(.top, Spacing.sm)

            HStack {
                Text("Nearby")
                    .font(.looHeadline)
                Spacer()
                if washrooms.isEmpty {
                    Text("Looking around…")
                        .font(.looCaption)
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.sm)

            if washrooms.isEmpty {
                // Placeholder cards while loading
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: Radius.card)
                                .fill(Color.surfaceElev)
                                .frame(width: 120, height: 110)
                                .shimmer()
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach(washrooms) { washroom in
                            NearbyCard(washroom: washroom)
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                }
            }
        }
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Radius.sheet))
        .padding(.horizontal, Spacing.sm)
        .padding(.bottom, Spacing.sm)
    }
}

// MARK: - Shimmer modifier (placeholder animation)

private struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay {
                LinearGradient(
                    colors: [.clear, .white.opacity(0.4), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .onAppear {
                    withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                        phase = 200
                    }
                }
            }
            .clipped()
    }
}

private extension View {
    func shimmer() -> some View { modifier(ShimmerModifier()) }
}
