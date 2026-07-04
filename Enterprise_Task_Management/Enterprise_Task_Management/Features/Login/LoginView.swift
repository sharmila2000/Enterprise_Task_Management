//
//  LoginView.swift
//  Enterprise_Task_Management
//
//  Created by Sharmila Ganesan on 04/07/26.
//
//  PURPOSE:
//  The Login screen View.
//  Shows how a View:
//  - Owns its ViewModel via @StateObject
//  - Uses two-way binding ($) to connect text fields to ViewModel properties
//  - Reacts to ViewModel state changes (isLoading, errorMessage, isLoggedIn)
//  - NEVER performs business logic — only delegates to ViewModel
//

import SwiftUI

// MARK: - LoginView

struct LoginView: View {

    // MARK: - ViewModel
    // Resolved from DIContainer so dependencies are properly injected
    @StateObject private var viewModel = LoginViewModel(
        authRepository: DIContainer.shared.resolve(AuthenticationRepositoryProtocol.self)
    )

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {

                    // ── Header ────────────────────────────────────────
                    headerSection

                    // ── Form ──────────────────────────────────────────
                    formSection

                    // ── Login Button ──────────────────────────────────
                    loginButton

                    Spacer(minLength: 20)
                }
                .padding(24)
            }
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.large)

            // ── Navigate to Dashboard on successful login ─────────────
            .navigationDestination(isPresented: $viewModel.isLoggedIn) {
                DashboardView()
            }

            // ── Error Alert ───────────────────────────────────────────
            .alert("Login Failed", isPresented: Binding(
                get: { viewModel.hasError },
                set: { if !$0 { viewModel.clearError() } }
            )) {
                Button("Try Again") { viewModel.clearError() }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.badge.key.fill")
                .font(.system(size: 56))
                .foregroundStyle(.blue)

            Text("Enterprise Task Management")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 20)
    }

    private var formSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Email Field
            VStack(alignment: .leading, spacing: 4) {
                Text("Email").font(.subheadline).foregroundStyle(.secondary)
                TextField("you@company.com", text: $viewModel.email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                if let emailError = viewModel.emailError {
                    Text(emailError).font(.caption).foregroundStyle(.red)
                }
            }

            // Password Field
            VStack(alignment: .leading, spacing: 4) {
                Text("Password").font(.subheadline).foregroundStyle(.secondary)
                SecureField("Min. 6 characters", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)

                if let passwordError = viewModel.passwordError {
                    Text(passwordError).font(.caption).foregroundStyle(.red)
                }
            }
        }
    }

    private var loginButton: some View {
        Button {
            viewModel.login()   // ← delegate action to ViewModel, never inline logic
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(viewModel.isLoginEnabled ? Color.blue : Color.gray.opacity(0.4))

                if viewModel.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Sign In")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
            }
            .frame(height: 50)
        }
        .disabled(!viewModel.isLoginEnabled || viewModel.isLoading)
    }
}

// MARK: - Preview

#Preview {
    LoginView()
}
