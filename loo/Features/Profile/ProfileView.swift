import SwiftUI

struct ProfileView: View {
    @Environment(AppRouter.self) private var router
    @State private var authRepo = AuthRepository.shared
    @Environment(\.dismiss)     private var dismiss

    var body: some View {
        List {
            Section {
                profileHeader
            }

            Section("My Activity") {
                NavigationLink {
                    // TODO: My submissions list (Week 5)
                    Text("My Submissions").font(.looHeadline)
                } label: {
                    Label("My Submissions", systemImage: "plus.circle")
                }
                NavigationLink {
                    // TODO: My reviews list (Week 5)
                    Text("My Reviews").font(.looHeadline)
                } label: {
                    Label("My Reviews", systemImage: "star")
                }
            }

            Section("App") {
                NavigationLink {
                    // TODO: Language picker (Week 6)
                    Text("Language").font(.looHeadline)
                } label: {
                    Label("Language", systemImage: "globe")
                }
                NavigationLink {
                    // TODO: About screen (Week 6)
                    Text("About Dhaka Loo v1.0").font(.looHeadline)
                } label: {
                    Label("About", systemImage: "info.circle")
                }
            }

            if authRepo.isSignedIn {
                Section {
                    Button("Sign Out", role: .destructive) {
                        authRepo.signOut()
                    }
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var profileHeader: some View {
        HStack(spacing: Spacing.md) {
            Circle()
                .fill(Color.brand.opacity(0.15))
                .frame(width: 64, height: 64)
                .overlay {
                    Text(authRepo.currentUser?.initials ?? "?")
                        .font(.looHeadline)
                        .foregroundStyle(Color.brand)
                }

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(authRepo.currentUser?.displayName ?? "Guest")
                    .font(.looHeadline)
                if !authRepo.isSignedIn {
                    Button("Sign In") {
                        router.isAuthPresented = true
                    }
                    .font(.looCaption)
                    .tint(Color.brand)
                } else if let phone = authRepo.currentUser?.phone {
                    Text(phone)
                        .font(.looCaption)
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .padding(.vertical, Spacing.xs)
    }
}
