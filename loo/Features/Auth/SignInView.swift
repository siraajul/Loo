import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.dismiss)      private var dismiss
    @State private var showPhoneOTP = false

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            Image(systemName: "toilet.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.brand)

            VStack(spacing: Spacing.sm) {
                Text("Dhaka Loo")
                    .font(.looTitle)
                Text("Find the nearest washroom, fast.")
                    .font(.looBody)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            VStack(spacing: Spacing.md) {
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    handleAppleSignIn(result)
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .cornerRadius(Radius.button / 2)

                Button {
                    showPhoneOTP = true
                } label: {
                    Label("Continue with Phone", systemImage: "phone.fill")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .buttonStyle(.bordered)
                .tint(Color.brand)
                .cornerRadius(Radius.button / 2)

                Button("Skip for now") {
                    dismiss()
                }
                .font(.looCaption)
                .foregroundStyle(Color.textSecondary)

                Text("Demo mode — backend auth ships in v0.3")
                    .font(.looCaption)
                    .foregroundStyle(Color.textSecondary)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xl)
        }
        .sheet(isPresented: $showPhoneOTP) {
            PhoneOTPView()
        }
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData  = credential.identityToken,
                  let idToken    = String(data: tokenData, encoding: .utf8) else { return }
            Task {
                // TODO: AuthRepository.shared.signInWithApple(idToken:, nonce:)
                _ = idToken
                dismiss()
            }
        case .failure:
            break
        }
    }
}
