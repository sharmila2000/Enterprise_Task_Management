//
//  LoginViewModel.swift
//  Enterprise_Task_Management
//
//  Created by Sharmila Ganesan on 04/07/26.
//
//  PURPOSE:
//  ViewModel for the Login screen.
//  Demonstrates MVVM + DI in a real feature:
//  - Extends BaseViewModel (free loading/error handling)
//  - Receives AuthenticationRepositoryProtocol via DI (not created internally)
//  - Exposes @Published state that LoginView binds to
//

import Foundation
import Combine

// MARK: - LoginViewModel

/// Drives the Login screen UI.
///
/// The View:
/// - Binds `email` and `password` fields to this ViewModel via `$email`, `$password`
/// - Reads `isLoading` to show/hide a spinner
/// - Reads `isLoggedIn` to trigger navigation to the Dashboard
/// - Calls `login()` when the button is tapped
class LoginViewModel: BaseViewModel {

    // MARK: - Input (bound to text fields in LoginView)
    @Published var email: String = ""
    @Published var password: String = ""

    // MARK: - Output (read by LoginView)
    @Published var isLoggedIn: Bool = false
    @Published var loggedInUser: AuthUser? = nil

    // MARK: - Validation
    var isLoginEnabled: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        password.count >= 6
    }

    var emailError: String? {
        guard !email.isEmpty else { return nil }
        return email.contains("@") ? nil : "Enter a valid email address."
    }

    var passwordError: String? {
        guard !password.isEmpty else { return nil }
        return password.count >= 6 ? nil : "Password must be at least 6 characters."
    }

    // MARK: - Dependencies (injected via DI)
    private let authRepository: AuthenticationRepositoryProtocol

    // MARK: - Init
    init(authRepository: AuthenticationRepositoryProtocol) {
        self.authRepository = authRepository
        super.init()
    }

    // MARK: - Actions

    /// Called when the user taps the "Login" button.
    /// Uses BaseViewModel.runTask() for automatic loading + error handling.
    func login() {
        guard isLoginEnabled else { return }

        runTask {
            let credentials = LoginCredentials(email: self.email, password: self.password)
            let user = try await self.authRepository.login(credentials: credentials)

            self.loggedInUser = user
            self.isLoggedIn = true
        }
    }

    /// Clears all form fields.
    func clearForm() {
        email = ""
        password = ""
        clearError()
    }
}
