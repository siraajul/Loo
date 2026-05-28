import SwiftUI

struct ProfileView: View {
    @Environment(AppRouter.self) private var router
    @State private var authRepo = AuthRepository.shared

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.brand.opacity(0.12), Color(.systemBackground)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.lg) {
                    header
                    if !authRepo.isSignedIn {
                        signInCard
                    } else {
                        statsRow
                    }
                    settingsGroup(title: "My Activity") {
                        ProfileRow(icon: "plus.circle.fill", iconTint: .brand,
                                   title: "My Submissions",
                                   subtitle: authRepo.isSignedIn ? nil : "Sign in to see your contributions",
                                   destination: AnyView(PlaceholderScreen(title: "My Submissions")))
                        ProfileRow(icon: "star.fill", iconTint: .accent,
                                   title: "My Reviews",
                                   subtitle: authRepo.isSignedIn ? nil : "Sign in to see your reviews",
                                   destination: AnyView(PlaceholderScreen(title: "My Reviews")))
                    }
                    settingsGroup(title: "App") {
                        ProfileRow(icon: "globe", iconTint: .menBlue,
                                   title: "Language",
                                   subtitle: "English · বাংলা coming",
                                   destination: AnyView(PlaceholderScreen(title: "Language")))
                        ProfileRow(icon: "info.circle.fill", iconTint: .textSecondary,
                                   title: "About",
                                   subtitle: "Loo v0.2 · made for Dhaka",
                                   destination: AnyView(AboutScreen()))
                    }
                    if authRepo.isSignedIn {
                        signOutButton
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.xl)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.brand.opacity(0.15))
                    .frame(width: 120, height: 120)
                Text(authRepo.currentUser?.initials ?? "👤")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(Color.brand)
            }
            .glassEffect(.regular, in: .circle)

            VStack(spacing: 4) {
                Text(authRepo.currentUser?.displayName ?? "Guest")
                    .font(.looTitle)
                if let phone = authRepo.currentUser?.phone {
                    Text(phone)
                        .font(.looCaption)
                        .foregroundStyle(Color.textSecondary)
                } else if !authRepo.isSignedIn {
                    Text("Sign in to track your contributions")
                        .font(.looCaption)
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .padding(.top, Spacing.md)
    }

    // MARK: - Sign-in card (guest mode)

    private var signInCard: some View {
        Button {
            router.isAuthPresented = true
        } label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 22, weight: .semibold))
                Text("Sign in")
                    .font(.looBody.weight(.semibold))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .opacity(0.6)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.md)
            .frame(height: 56)
            .background(Color.brand, in: Capsule())
        }
    }

    // MARK: - Stats (signed-in)

    private var statsRow: some View {
        HStack(spacing: Spacing.sm) {
            StatPill(value: "\(authRepo.currentUser?.submissionCount ?? 0)",
                     label: "Submitted", icon: "plus.circle.fill", tint: .brand)
            StatPill(value: "0", label: "Reviews", icon: "star.fill", tint: .accent)
            StatPill(value: "0", label: "Verified", icon: "checkmark.seal.fill", tint: .success)
        }
    }

    // MARK: - Settings group

    @ViewBuilder
    private func settingsGroup<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(.looCaption)
                .foregroundStyle(Color.textSecondary)
                .padding(.leading, Spacing.sm)
            VStack(spacing: Spacing.xs) {
                content()
            }
        }
    }

    // MARK: - Sign-out

    private var signOutButton: some View {
        Button(role: .destructive) {
            authRepo.signOut()
        } label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Sign Out").font(.looBody.weight(.semibold))
            }
            .foregroundStyle(Color.danger)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
        }
        .glassEffect(.regular.interactive(), in: .capsule)
    }
}

// MARK: - Sub-views

private struct ProfileRow: View {
    let icon: String
    let iconTint: Color
    let title: String
    var subtitle: String? = nil
    let destination: AnyView

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(iconTint)
                    .frame(width: 32)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.looBody)
                        .foregroundStyle(Color.textPrimary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.looCaption)
                            .foregroundStyle(Color.textSecondary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.textSecondary)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: Radius.card))
    }
}

private struct StatPill: View {
    let value: String
    let label: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint)
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.textPrimary)
            Text(label)
                .font(.looCaption)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.sm)
        .glassEffect(.regular, in: .rect(cornerRadius: Radius.card))
    }
}

private struct PlaceholderScreen: View {
    let title: String

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "hammer.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.brand)
                .frame(width: 120, height: 120)
                .glassEffect(.regular, in: .circle)
            Text("\(title) — coming in v0.3")
                .font(.looHeadline)
            Text("Backend integration is the next milestone. Star the repo on GitHub to follow progress.")
                .font(.looCaption)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(colors: [Color.brand.opacity(0.08), Color(.systemBackground)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AboutScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                Image(systemName: "toilet.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.brand)
                    .frame(width: 140, height: 140)
                    .glassEffect(.regular, in: .circle)

                VStack(spacing: 4) {
                    Text("Loo").font(.looTitle)
                    Text("v0.2 · Local Fit & Inclusivity")
                        .font(.looCaption)
                        .foregroundStyle(Color.textSecondary)
                }

                Text("Loo helps you find clean public washrooms in Dhaka — inclusive of women, families, and the hijra community. Built on OpenStreetMap, free forever, powered by you.")
                    .font(.looBody)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.textPrimary)
                    .padding(.horizontal, Spacing.lg)

                VStack(spacing: Spacing.sm) {
                    AboutLink(icon: "link",       title: "GitHub repo",       url: "https://github.com/siraajul/Loo")
                    AboutLink(icon: "map.fill",   title: "OpenStreetMap",     url: "https://www.openstreetmap.org/copyright")
                    AboutLink(icon: "heart.fill", title: "MapLibre",          url: "https://maplibre.org")
                }
                .padding(.horizontal, Spacing.md)
            }
            .padding(.vertical, Spacing.lg)
        }
        .background(
            LinearGradient(colors: [Color.brand.opacity(0.08), Color(.systemBackground)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AboutLink: View {
    let icon: String
    let title: String
    let url: String

    var body: some View {
        Link(destination: URL(string: url)!) {
            HStack(spacing: Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.brand)
                    .frame(width: 32)
                Text(title)
                    .font(.looBody)
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.textSecondary)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
        }
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: Radius.card))
    }
}
