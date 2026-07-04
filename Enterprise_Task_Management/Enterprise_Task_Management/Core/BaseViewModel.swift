//
//  BaseViewModel.swift
//  Enterprise_Task_Management
//
//  Created by Sharmila Ganesan on 04/07/26.
//
//  PURPOSE:
//  The foundation for ALL ViewModels in the app.
//  Provides shared state (loading, error) and utilities so every
//  feature ViewModel gets them for free by just inheriting BaseViewModel.
//
//  CONCEPTS DEMONSTRATED:
//  - MVVM: ViewModel is the bridge between View and Repository.
//  - @MainActor: UI state must always be updated on the main thread.
//  - ObservableObject + @Published: SwiftUI watches these for changes.
//  - Combine (AnyCancellable): Manages async stream subscriptions.
//

import Foundation
import Combine

// MARK: - BaseViewModel

/// Abstract base class for all ViewModels.
///
/// **What is a ViewModel?**
/// In MVVM, the ViewModel sits between the View (UI) and the Model (data/business logic).
/// - The **View** observes the ViewModel's `@Published` properties and re-renders when they change.
/// - The **ViewModel** calls the Repository to fetch/save data, then updates its `@Published` state.
/// - The **View** never directly accesses a Repository — it only talks to the ViewModel.
///
///```
/// ┌──────────┐    observes    ┌─────────────┐    calls    ┌────────────┐
/// │   View   │ ─────────────▶ │  ViewModel  │ ──────────▶ │ Repository │
/// │(SwiftUI) │ ◀───@Published─ │(ObservObj) │ ◀──data──── │  (Data)    │
/// └──────────┘                └─────────────┘             └────────────┘
///```
///
/// **How to use:**
/// ```swift
/// class TaskViewModel: BaseViewModel {
///     @Published var tasks: [Task] = []
///
///     func loadTasks() {
///         startLoading()
///         // fetch tasks...
///         stopLoading()
///     }
/// }
/// ```
@MainActor
class BaseViewModel: ObservableObject {

    // MARK: - Published State

    /// Indicates that an async operation is in progress.
    /// Bind this to a ProgressView in the UI to show a spinner.
    @Published var isLoading: Bool = false

    /// Holds the latest error message, if any.
    /// Set this to display an error banner or alert in the UI.
    @Published var errorMessage: String? = nil

    /// Derived flag — true when there is an active error to display.
    var hasError: Bool { errorMessage != nil }

    // MARK: - Combine

    /// Stores all active Combine subscriptions.
    /// When the ViewModel is deallocated, cancellables is released,
    /// which automatically cancels all subscriptions — preventing memory leaks.
    var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init() {}

    // MARK: - Loading State Helpers

    /// Call this BEFORE starting any async operation (network call, DB fetch, etc.)
    func startLoading() {
        isLoading = true
        clearError()          // clear any previous error when starting fresh
    }

    /// Call this AFTER an async operation finishes (success or failure).
    func stopLoading() {
        isLoading = false
    }

    // MARK: - Error Handling

    /// Converts any Error into a user-friendly message and stops the loading spinner.
    ///
    /// - Parameter error: The error thrown by a repository or service.
    func handleError(_ error: Error) {
        stopLoading()
        errorMessage = error.localizedDescription
    }

    /// Clears the current error state.
    /// Call this when the user dismisses an error alert.
    func clearError() {
        errorMessage = nil
    }

    // MARK: - Convenience: Run async task with automatic loading + error handling

    /// Wraps an async operation with automatic loading state and error handling.
    ///
    /// **Usage:**
    /// ```swift
    /// func loadTasks() {
    ///     runTask {
    ///         self.tasks = try await self.repository.fetchAll()
    ///     }
    /// }
    /// ```
    /// - Parameter operation: The async throwing closure to execute.
    func runTask(_ operation: @escaping () async throws -> Void) {
        startLoading()
        Task {
            do {
                try await operation()
                stopLoading()
            } catch {
                handleError(error)
            }
        }
    }
}
