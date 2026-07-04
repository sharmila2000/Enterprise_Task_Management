//
//  BaseRepository.swift
//  Enterprise_Task_Management
//
//  Created by Sharmila Ganesan on 04/07/26.
//
//  PURPOSE:
//  Defines the contract (protocol) for all data repositories and provides
//  a shared base class with common utilities like logging and error mapping.
//
//  CONCEPTS DEMONSTRATED:
//  - Repository Pattern: Abstracts data access (API, DB, cache) behind a protocol.
//  - Protocol + Generics (associatedtype): Each repository defines its own Entity type.
//  - Dependency Injection: ViewModels depend on the PROTOCOL, not a concrete class.
//    This lets us swap real data sources with mock data during testing.
//

import Foundation

// MARK: - RepositoryProtocol

/// The contract every repository in the app must fulfill.
///
/// **What is the Repository Pattern?**
/// The Repository Pattern hides WHERE data comes from (API? CoreData? UserDefaults?)
/// behind a clean protocol. The ViewModel calls `repository.fetchAll()` and doesn't
/// care if data comes from the network or a local database.
///
/// ```
/// ┌─────────────┐       ┌──────────────────────┐       ┌──────────────┐
/// │  ViewModel  │──────▶│  RepositoryProtocol  │◀──────│  TaskRepo   │ (real API)
/// │             │       │  (abstract contract) │◀──────│  MockRepo   │ (fake data)
/// └─────────────┘       └──────────────────────┘       └──────────────┘
/// ```
///
/// **How to use:**
/// ```swift
/// protocol TaskRepositoryProtocol: RepositoryProtocol where Entity == Task {}
///
/// class TaskRepository: BaseRepository<Task>, TaskRepositoryProtocol {
///     func fetchAll() async throws -> [Task] { ... }
/// }
/// ```
protocol RepositoryProtocol {

    // Each conforming repository declares its own data model type.
    // e.g., TaskRepository uses `Entity = Task`
    associatedtype Entity

    /// Fetch all records.
    func fetchAll() async throws -> [Entity]

    /// Fetch a single record by its unique identifier.
    func fetchById(_ id: UUID) async throws -> Entity?

    /// Persist a new record and return the saved version.
    func create(_ entity: Entity) async throws -> Entity

    /// Update an existing record and return the updated version.
    func update(_ entity: Entity) async throws -> Entity

    /// Delete a record by its unique identifier.
    func delete(id: UUID) async throws
}

// MARK: - BaseRepository

/// Base class that provides shared utilities for all concrete repositories.
///
/// Subclass this for each feature:
/// ```swift
/// class TaskRepository: BaseRepository<Task>, TaskRepositoryProtocol { ... }
/// ```
class BaseRepository<Entity> {

    // MARK: - Init
    init() {}

    // MARK: - Error Mapping

    /// Converts any generic Error into a typed AppError.
    ///
    /// If the error is already an AppError, it passes through unchanged.
    /// Otherwise it wraps it as `.unknown`.
    func mapError(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError        // already typed, pass through
        }
        return AppError.unknown(error.localizedDescription)
    }

    // MARK: - Logging

    /// Prints a debug message tagged with the repository class name.
    /// No-ops in Release builds — zero performance cost in production.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - level: Severity level (.info / .warning / .error).
    func log(_ message: String, level: LogLevel = .info) {
        #if DEBUG
        let tag = String(describing: type(of: self))
        print("\(level.symbol) [\(tag)] \(message)")
        #endif
    }
}

// MARK: - LogLevel

/// Severity levels for repository/debug logging.
enum LogLevel {
    case info
    case warning
    case error

    /// Emoji symbol printed before each log message.
    var symbol: String {
        switch self {
        case .info:    return "ℹ️"
        case .warning: return "⚠️"
        case .error:   return "❌"
        }
    }
}
