import SwiftUI

struct PhoneOTPView: View {
    @State private var phone      = ""
    @State private var otp        = ""
    @State private var isOTPSent  = false
    @State private var isLoading  = false
    @State private var errorMsg: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.xl) {
                Spacer()
                if isOTPSent {
                    otpInputView
                } else {
                    phoneInputView
                }
                Spacer()
            }
            .padding(Spacing.lg)
            .navigationTitle(isOTPSent ? "Enter OTP" : "Phone Number")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Error", isPresented: .constant(errorMsg != nil)) {
                Button("OK") { errorMsg = nil }
            } message: {
                Text(errorMsg ?? "")
            }
        }
    }

    private var phoneInputView: some View {
        VStack(spacing: Spacing.lg) {
            Text("Enter your Bangladesh mobile number")
                .font(.looBody)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)

            HStack(spacing: Spacing.sm) {
                Text("+880")
                    .font(.looBody)
                    .padding(Spacing.md)
                    .background(Color.surfaceElev, in: RoundedRectangle(cornerRadius: 12))

                TextField("1XXXXXXXXX", text: $phone)
                    .keyboardType(.phonePad)
                    .font(.looBody)
                    .padding(Spacing.md)
                    .background(Color.surfaceElev, in: RoundedRectangle(cornerRadius: 12))
            }

            actionButton(title: "Send OTP", disabled: phone.count < 10) {
                Task { await sendOTP() }
            }
        }
    }

    private var otpInputView: some View {
        VStack(spacing: Spacing.lg) {
            Text("Enter the 6-digit code sent to +880 \(phone)")
                .font(.looBody)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)

            TextField("000000", text: $otp)
                .keyboardType(.numberPad)
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .multilineTextAlignment(.center)
                .padding(Spacing.md)
                .background(Color.surfaceElev, in: RoundedRectangle(cornerRadius: 12))

            actionButton(title: "Verify", disabled: otp.count < 6) {
                Task { await verifyOTP() }
            }
        }
    }

    private func actionButton(title: String, disabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Group {
                if isLoading { ProgressView().tint(.white) }
                else { Text(title) }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .buttonStyle(.borderedProminent)
        .tint(Color.brand)
        .disabled(disabled || isLoading)
        .cornerRadius(Radius.button / 2)
    }

    private func sendOTP() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await AuthRepository.shared.sendOTP(phone: "+880\(phone)")
            isOTPSent = true
        } catch {
            errorMsg = error.localizedDescription
        }
    }

    private func verifyOTP() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await AuthRepository.shared.verifyOTP(phone: "+880\(phone)", token: otp)
            dismiss()
        } catch {
            errorMsg = error.localizedDescription
        }
    }
}
