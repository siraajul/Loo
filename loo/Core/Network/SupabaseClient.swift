import Foundation

// TODO: Replace with the official supabase-swift package once added.
// TODO: Set real values from your Supabase project settings (Settings → API).
enum SupabaseConfig {
    static let projectURL = URL(string: "https://your-project-id.supabase.co")!
    static let anonKey    = "your-anon-key-here"
}

// HTTP-only actor: sends requests, returns raw Data.
// Decoding is intentionally left to callers so no Sendable constraint is needed on T.
actor SupabaseClient {
    static let shared = SupabaseClient()

    private let session: URLSession = {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 30
        return URLSession(configuration: cfg)
    }()

    private var authToken: String?

    func setAuthToken(_ token: String?) {
        authToken = token
    }

    // Calls a Supabase RPC function and returns raw response bytes.
    func rpc(functionName: String, body: Data) async throws -> Data {
        var request = URLRequest(
            url: SupabaseConfig.projectURL.appendingPathComponent("rest/v1/rpc/\(functionName)"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = body
        let (data, _) = try await session.data(for: request)
        return data
    }

    // Generic REST GET with optional query string.
    func get(path: String, query: [String: String] = [:]) async throws -> Data {
        var components = URLComponents(
            url: SupabaseConfig.projectURL.appendingPathComponent("rest/v1/\(path)"),
            resolvingAgainstBaseURL: false)!
        if !query.isEmpty {
            components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        var request = URLRequest(url: components.url!)
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (data, _) = try await session.data(for: request)
        return data
    }

    // Generic REST POST.
    func post(path: String, body: Data) async throws -> Data {
        var request = URLRequest(
            url: SupabaseConfig.projectURL.appendingPathComponent("rest/v1/\(path)"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = body
        let (data, _) = try await session.data(for: request)
        return data
    }
}

// Shared JSON coders configured for Supabase conventions.
extension JSONDecoder {
    static let supabase: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy  = .convertFromSnakeCase
        d.dateDecodingStrategy = .iso8601
        return d
    }()
}

extension JSONEncoder {
    static let supabase: JSONEncoder = {
        let e = JSONEncoder()
        e.keyEncodingStrategy  = .convertToSnakeCase
        e.dateEncodingStrategy = .iso8601
        return e
    }()
}
