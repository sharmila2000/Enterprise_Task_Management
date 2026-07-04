//
//  APIClient.swift
//  Enterprise_Task_Management
//
//  Created by Sharmila Ganesan on 04/07/26.
//
//  PURPOSE:
//  The single gateway for ALL network requests in the app.
//  Every repository uses APIClient to talk to the backend — no repository
//  ever creates its own URLSession or writes raw networking code.
//
//  CONCEPTS DEMONSTRATED:
//  - Single Responsibility: One class owns all HTTP communication.
//  - Generic functions: One `request<T>` method works for any Decodable response.
//  - async/await: Modern Swift concurrency instead of callbacks.
//  - Error mapping: Network errors are converted to AppError before returning.
//

import Foundation

// MARK: - HTTPMethod

/// Supported HTTP methods.
enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case PATCH
    case DELETE
}

// MARK: - APIEndpoint

/// Represents a fully configured API endpoint.
///
/// Usage:
/// ```swift
/// let endpoint = APIEndpoint(
///     path: "/tasks",
///     method: .GET
/// )
/// ```
struct APIEndpoint {
    let path: String
    let method: HTTPMethod
    var queryItems: [URLQueryItem]? = nil
    var body: Encodable? = nil
    var headers: [String: String] = [:]
}

// MARK: - APIClient

/// Handles all HTTP communication with the backend API.
///
/// Repositories inject this via DIContainer and call `request(...)` to
/// fetch or mutate data. The raw URLSession details are hidden here.
///
/// Future tasks will add:
/// - Authentication token injection (Bearer token in headers)
/// - Request/response logging middleware
/// - Retry logic for transient failures
final class APIClient {

    // MARK: - Configuration

    /// Base URL for all API requests. Change this to point to staging/production.
    private let baseURL: String

    /// The URLSession used for all requests. Injected for testability.
    private let session: URLSession

    // MARK: - Init

    init(
        baseURL: String = "https://api.enterprise-tasks.com/v1",
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    // MARK: - Generic Request

    /// Performs an HTTP request and decodes the response into type `T`.
    ///
    /// - Parameter endpoint: The endpoint configuration (path, method, body, etc.)
    /// - Returns: A decoded instance of `T`.
    /// - Throws: `AppError` describing what went wrong.
    ///
    /// Usage:
    /// ```swift
    /// let tasks: [TaskModel] = try await apiClient.request(
    ///     APIEndpoint(path: "/tasks", method: .GET)
    /// )
    /// ```
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        // 1. Build the full URL
        guard var urlComponents = URLComponents(string: baseURL + endpoint.path) else {
            throw AppError.networkError("Invalid URL: \(baseURL + endpoint.path)")
        }
        urlComponents.queryItems = endpoint.queryItems

        guard let url = urlComponents.url else {
            throw AppError.networkError("Could not construct URL.")
        }

        // 2. Build the URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Apply custom headers
        endpoint.headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        // Encode body if present
        if let body = endpoint.body {
            request.httpBody = try JSONEncoder().encode(AnyEncodable(body))
        }

        // 3. Execute the request
        log("→ \(endpoint.method.rawValue) \(url.absoluteString)")

        let (data, response) = try await session.data(for: request)

        // 4. Validate HTTP status code
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.networkError("Invalid server response.")
        }

        log("← \(httpResponse.statusCode) \(url.lastPathComponent)")

        switch httpResponse.statusCode {
        case 200...299:
            break                                          // success
        case 401:
            throw AppError.unauthorized
        case 404:
            throw AppError.notFound(endpoint.path)
        case 500...599:
            throw AppError.serverError(httpResponse.statusCode)
        default:
            throw AppError.serverError(httpResponse.statusCode)
        }

        // 5. Decode the response
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            throw AppError.decodingError(error.localizedDescription)
        }
    }

    // MARK: - Fire-and-forget (no response body expected)

    /// Sends a request where no response body is expected (e.g., DELETE).
    func send(_ endpoint: APIEndpoint) async throws {
        let _: EmptyResponse = try await request(endpoint)
    }

    // MARK: - Logging

    private func log(_ message: String) {
        #if DEBUG
        print("🌐 [APIClient] \(message)")
        #endif
    }
}

// MARK: - Helpers

/// Type-erased Encodable wrapper (lets us encode `any Encodable` as a body).
private struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void

    init(_ wrapped: Encodable) {
        encodeFunc = wrapped.encode
    }

    func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}

/// Used as the return type for endpoints that return an empty body.
private struct EmptyResponse: Decodable {}
