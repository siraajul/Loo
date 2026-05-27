import SwiftUI
import CoreLocation

struct SubmitView: View {
    let prefilledCoordinate: CLLocationCoordinate2D?
    @State private var form    = SubmitFormState()
    @State private var isLoading = false
    @State private var showConfirmation = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            SubmitForm(form: $form)
                .navigationTitle("Add Washroom")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Submit") {
                            Task { await submitForm() }
                        }
                        .tint(Color.brand)
                        .disabled(!form.isValid || isLoading)
                        .overlay {
                            if isLoading { ProgressView().tint(.brand) }
                        }
                    }
                }
                .alert("Submitted!", isPresented: $showConfirmation) {
                    Button("Done") { dismiss() }
                } message: {
                    Text("Thanks! A moderator will review your submission shortly.")
                }
        }
        .onAppear {
            if let coord = prefilledCoordinate {
                form.latitude  = coord.latitude
                form.longitude = coord.longitude
            }
        }
    }

    private func submitForm() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let payload = SubmissionPayload(
                washroomId:   nil,
                proposedData: form.toProposedData()
            )
            try await SubmissionRepository.shared.submit(payload)
            showConfirmation = true
        } catch {
            // TODO: Show error toast
        }
    }
}
