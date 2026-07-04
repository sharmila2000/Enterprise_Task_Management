//
//  AppError.swift
//  Enterprise_Task_Management
//
//  Created by Sharmila Ganesan on 04/07/26.
//
//  PURPOSE:
//  A centralized error type for the entire app.
//  Every layer (Repository, Service, ViewModel) maps errors to AppError
//  so that the UI always receives a clean, user-friendly message.
//

import Foundation

// MARK: - AppError

/// A unified error enum covering all failure scenarios in the app.
///
/// **Why a centralized error type?**
/// Without it, each layer invents its own error format, making it hard
/// to display consistent messages in the UI or handle errors uniformly.
///
/// **Usage:**
/// ```swift
/// throw AppError.notFound("Task")         // → "Task not found."
/// throw AppError.unauthorized             // → "You are not authorized."
/// throw AppError.serverError(500)         // → "Server error (code 500)."
/// ```
enum AppError: LocalizedError, Equatable {

    // MARK: - Cases

    /// A resource was not found (e.g., a task with a specific ID).
    case notFound(String)

    /// A network/connectivity problem occurred.
    case networkError(String)

    /// Parsing or decoding data failed (e.g., bad JSON from API).
    case decodingError(String)

    /// The user is not authenticated or their session expired.
    case unauthorized

    /// The server returned an HTTP error code.
    case serverError(Int)

    /// An unexpected or unclassified error.
    case unknown(String)

    // MARK: - LocalizedError

    /// Human-readable description shown in the UI.
    var errorDescription: String? {
        switch self {
        case .notFound(let item):
            return "\(item) not found."
        case .networkError(let message):
            return "Network error: \(message)"
        case .decodingError(let message):
            return "Data parsing error: \(message)"
        case .unauthorized:
            return "You are not authorized. Please log in again."
        case .serverError(let code):
            return "Server error (code \(code)). Please try again later."
        case .unknown(let message):
            return "An unexpected error occurred: \(message)"
        }
    }

    /// Short title for alert dialogs.
    var failureReason: String? {
        switch self {
        case .notFound:        return "Not Found"
        case .networkError:    return "Network Problem"
        case .decodingError:   return "Data Error"
        case .unauthorized:    return "Unauthorized"
        case .serverError:     return "Server Error"
        case .unknown:         return "Unknown Error"
        }
    }
}
