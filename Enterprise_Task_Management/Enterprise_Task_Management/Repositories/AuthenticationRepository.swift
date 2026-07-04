//
//  AuthenticationRepository.swift
//  Enterprise_Task_Management
//
//  Created by Sharmila Ganesan on 04/07/26.
//
//  PURPOSE:
//  Concrete repository for all authentication operations.
//  Handles login, logout, registration, and session management.
//
//  NOTE: Real token storage (Keychain) and API calls come in a future task.
//  This file establishes the protocol contract and stub implementation.
//

import Foundation

// MARK: - AuthUser

/// Represents an authenticated user session.
struct AuthUser: Codable, Equatable {
    let id: UUID
    let email: String
    let fullName: String
    let role: UserRole
    let token: String           // Bearer token for API requests

    var initials: String {
        let parts = fullName.split(separator: " ")
        return parts.compactMap { $0.first }.map(String.init).joined()
    }
}

// MARK: - UserRole

enum UserRole: String, Codable {
    case admin   = "Admin"
    case manager = "Manager"
    case member  = "Member"
}

// MARK: - LoginCredentials

/// Payload sent to the login endpoint.
struct LoginCredentials: Encodable {
    let email: String
    let password: String
}

// MARK: - AuthenticationRepositoryProtocol

/// Contract for authentication operations.
/// LoginViewModel depends on this protocol — not on the concrete class.
protocol AuthenticationRepositoryProtocol {

    /// Authenticate a user with email and password.
    /// Returns an AuthUser with a token on success.
    func login(credentials: LoginCredentials) async throws -> AuthUser

    /// Invalidate the current session token on the server.
    func logout() async throws

    /// Returns the currently cached user session, if any.
    func currentUser() -> AuthUser?

    /// True if the user has a valid active session.
    var isAuthenticated: Bool { get }
}

// MARK: - AuthenticationRepository

/// Concrete authentication repository.
/// Manages login/logout and persists the session token.
///
/// Future tasks will add:
/// - Keychain storage for the token (secure)
/// - Token refresh logic
/// - Biometric authentication
final class AuthenticationRepository: BaseRepository<AuthUser>, AuthenticationRepositoryProtocol {

    // MARK: - Dependencies
    private let apiClient: APIClient

    // MARK: - Session Cache (in-memory for now; Keychain comes later)
    private var cachedUser: AuthUser? = nil

    // MARK: - Init
    init(apiClient: APIClient) {
        self.apiClient = apiClient
        super.init()
        log("AuthenticationRepository initialized")
    }

    // MARK: - AuthenticationRepositoryProtocol

    var isAuthenticated: Bool {
        cachedUser != nil
    }

    func currentUser() -> AuthUser? {
        cachedUser
    }

    func login(credentials: LoginCredentials) async throws -> AuthUser {
        log("Attempting login for: \(credentials.email)")

        // TODO (future task): call real API
        // let user: AuthUser = try await apiClient.request(
        //     APIEndpoint(path: "/auth/login", method: .POST, body: credentials)
        // )

        // Stub: simulate a successful login after a short delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // Basic validation
        guard credentials.email.contains("@"), !credentials.password.isEmpty else {
            throw AppError.networkError("Invalid email or password.")
        }

        let user = AuthUser(
            id: UUID(),
            email: credentials.email,
            fullName: "Sharmila Ganesan",
            role: .admin,
            token: "stub-token-\(UUID().uuidString)"
        )

        cachedUser = user
        log("Login successful for: \(user.email)")
        return user
    }

    func logout() async throws {
        log("Logging out user: \(cachedUser?.email ?? "unknown")")

        // TODO: try await apiClient.send(APIEndpoint(path: "/auth/logout", method: .POST))

        cachedUser = nil
        log("Logout successful")
    }
}
