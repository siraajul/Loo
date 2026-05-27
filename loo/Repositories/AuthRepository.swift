import Foundation
import Observation

@Observable
@MainActor
final class AuthRepository {
    static let shared = AuthRepository()

    private(set) var currentUser: UserProfile?
    private(set) var isSignedIn = false

    func signInWithApple(idToken: String, nonce: String) async throws {
        // TODO: Call Supabase signInWithIdToken(provider: .apple, idToken:, nonce:)
        isSignedIn = true
    }

    func sendOTP(phone: String) async throws {
        // TODO: Call Supabase auth.signInWithOTP(phone:)
    }

    func verifyOTP(phone: String, token: String) async throws {
        // TODO: Call Supabase auth.verifyOTP(phone:, token:, type: .sms)
        isSignedIn = true
    }

    func signOut() {
        currentUser = nil
        isSignedIn  = false
        // TODO: Call Supabase auth.signOut()
    }
}
