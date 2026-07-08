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
//  - Uses AppTextField, AppButton, AppCard from Components/
//    and theme colors/fonts from Theme/
//

import SwiftUI

// MARK: - LoginView

struct LoginView: View {

    // MARK: - ViewModel
    @StateObject private var viewModel = LoginViewModel(
        authRepository: DIContainer.shared.resolve(AuthenticationRepositoryProtocol.self)
    )

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    headerSection
                    formSection
                    // AppButton replaces the manual ZStack + RoundedRectangle
                    AppButton(
                        title: "Sign In",
                        isLoading: viewModel.isLoading,
                        isDisabled: !viewModel.isLoginEnabled
                    ) {
                        viewModel.login()
                    }
                }
                .padding(24)
            }
            .background(Color.appBackground)
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(isPresented: $viewModel.isLoggedIn) {
                DashboardView()
            }
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
                .foregroundStyle(Color.appPrimary)           // ← theme color

            Text("Enterprise Task Management")
                .appFont(.subhead)                      // ← theme font
                .foregroundStyle(Color.appTextSecondary)     // ← theme color
        }
        .padding(.top, 20)
    }

    private var formSection: some View {
        // AppTextField replaces the manual VStack + label + field + error per field
        VStack(spacing: 16) {
            AppTextField(
                label: "Email",
                placeholder: "you@company.com",
                text: $viewModel.email,
                errorMessage: viewModel.emailError,
                keyboardType: .emailAddress,
                autocapitalization: .never
            )
            AppTextField(
                label: "Password",
                placeholder: "Min. 6 characters",
                text: $viewModel.password,
                errorMessage: viewModel.passwordError,
                isSecure: true
            )
        }
    }
}

// MARK: - Preview

#Preview("Light") {
    LoginView()
}

#Preview("Dark") {
    LoginView()
        .preferredColorScheme(.dark)    // ← test dark mode directly in canvas
}
