import SwiftUI

struct OnboardingView: View {
    @Environment(LocationService.self) private var locationService
    @AppStorage("hasSeenOnboarding")   private var hasSeenOnboarding = false
    @State private var pageIndex = 0

    private let pages: [OnboardingPage] = [
        .init(
            icon:     "toilet.fill",
            iconTint: .brand,
            title:    "Find a clean washroom in Dhaka, fast",
            body:     "Loo maps real public washrooms — malls, mosques, hospitals, petrol pumps — with live distance and turn-by-turn compass guidance."
        ),
        .init(
            icon:     "person.2.fill",
            iconTint: .womenPink,
            title:    "Built for everyone",
            body:     "Every listing shows if it's women-friendly, family-friendly, or a third-gender inclusive space. Mosques surface wudu areas. Cleanliness scored separately. Verified by the community.",
            badges:   [
                .init(icon: "checkmark.seal.fill", label: "Women friendly", tint: .womenPink),
                .init(icon: "figure.stand.dress.line.vertical.figure", label: "Hijra inclusive", tint: .hijraPurple),
                .init(icon: "drop.fill", label: "Wudu area", tint: .brand),
                .init(icon: "figure.and.child.holdinghands", label: "Baby changing", tint: .brand),
            ]
        ),
        .init(
            icon:     "location.fill",
            iconTint: .brand,
            title:    "We need your location",
            body:     "To show the closest washrooms and rotate the compass arrow toward your destination. Used only while the app is open — never shared, never tracked.",
            isPermissionPage: true
        ),
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.brand.opacity(0.12), Color(.systemBackground)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                pageContent
                bottomBar
            }
        }
    }

    private var topBar: some View {
        HStack {
            Spacer()
            Button("Skip") { finish(requestingPermission: false) }
                .font(.looCaption)
                .foregroundStyle(Color.textSecondary)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.md)
    }

    private var pageContent: some View {
        TabView(selection: $pageIndex) {
            ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                OnboardingPageView(page: page).tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }

    private var bottomBar: some View {
        VStack(spacing: Spacing.md) {
            pageDots
            primaryButton
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.xl)
    }

    private var pageDots: some View {
        HStack(spacing: 8) {
            ForEach(pages.indices, id: \.self) { i in
                Capsule()
                    .fill(i == pageIndex ? Color.brand : Color.textSecondary.opacity(0.3))
                    .frame(width: i == pageIndex ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: pageIndex)
            }
        }
    }

    private var primaryButton: some View {
        Button(action: primaryAction) {
            Text(primaryButtonTitle)
                .font(.looBody.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.brand, in: Capsule())
        }
    }

    private var primaryButtonTitle: String {
        if pages[pageIndex].isPermissionPage { return "Allow location" }
        return pageIndex == pages.count - 1 ? "Get started" : "Continue"
    }

    private func primaryAction() {
        let page = pages[pageIndex]
        if page.isPermissionPage {
            finish(requestingPermission: true)
            return
        }
        withAnimation { pageIndex = min(pageIndex + 1, pages.count - 1) }
    }

    private func finish(requestingPermission: Bool) {
        if requestingPermission { locationService.requestPermission() }
        hasSeenOnboarding = true
    }
}

// MARK: - Page model + view

private struct OnboardingPage {
    let icon: String
    let iconTint: Color
    let title: String
    let body: String
    var badges: [Badge] = []
    var isPermissionPage = false

    struct Badge {
        let icon: String
        let label: String
        let tint: Color
    }
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            Image(systemName: page.icon)
                .font(.system(size: 96, weight: .bold))
                .foregroundStyle(page.iconTint)
                .frame(width: 160, height: 160)
                .glassEffect(.regular, in: .circle)

            VStack(spacing: Spacing.md) {
                Text(page.title)
                    .font(.looTitle)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.md)

                Text(page.body)
                    .font(.looBody)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.lg)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !page.badges.isEmpty {
                badgeGrid
            }

            Spacer()
        }
    }

    private var badgeGrid: some View {
        LazyVGrid(
            columns: [.init(.flexible()), .init(.flexible())],
            spacing: Spacing.sm
        ) {
            ForEach(page.badges, id: \.label) { badge in
                HStack(spacing: Spacing.sm) {
                    Image(systemName: badge.icon)
                        .foregroundStyle(badge.tint)
                    Text(badge.label)
                        .font(.looCaption)
                        .foregroundStyle(Color.textPrimary)
                }
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xs)
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassEffect(.regular, in: .capsule)
            }
        }
        .padding(.horizontal, Spacing.lg)
    }
}
