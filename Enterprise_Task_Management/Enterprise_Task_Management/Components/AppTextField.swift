//
//  AppTextField.swift
//  Enterprise_Task_Management
//
//  PURPOSE:
//  A styled, reusable text field that bundles label + input + inline error
//  into one component. Every form field becomes a single line of code.
//
//  KEY CONCEPT — Composition:
//  Instead of repeating VStack { label + TextField + error } in every form,
//  we compose those three pieces into AppTextField once.
//  The caller only provides the data; the component owns the layout.
//
//  HOW TO USE:
//      AppTextField(
//          label: "Email",
//          placeholder: "you@company.com",
//          text: $viewModel.email,
//          errorMessage: viewModel.emailError,
//          keyboardType: .emailAddress
//      )
//      AppTextField(
//          label: "Password",
//          placeholder: "Min. 6 characters",
//          text: $viewModel.password,
//          isSecure: true
//      )
//

import SwiftUI

// MARK: - AppTextField

struct AppTextField: View {

    // MARK: - Properties

    let label: String
    let placeholder: String
    @Binding var text: String

    var errorMessage: String?                           = nil
    var isSecure: Bool                                  = false
    var keyboardType: UIKeyboardType                    = .default
    var autocapitalization: TextInputAutocapitalization = .sentences

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            // ── Label ─────────────────────────────────────────────────
            Text(label)
                .appFont(.subhead)
                .foregroundStyle(Color.appTextSecondary)

            // ── Input ─────────────────────────────────────────────────
            // `Group` lets us apply the same modifiers to both branches
            // (TextField and SecureField) without repeating them.
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                        .textInputAutocapitalization(autocapitalization)
                        .autocorrectionDisabled()
                }
            }
            .appFont(.body)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.appSurface)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            // Border turns red when there is a validation error
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        errorMessage != nil ? Color.appError : Color.appBorder,
                        lineWidth: 1
                    )
            )

            // ── Inline Error ──────────────────────────────────────────
            // Only shown when errorMessage is non-nil.
            if let error = errorMessage {
                Text(error)
                    .appFont(.caption)
                    .foregroundStyle(Color.appError)
            }
        }
    }
}

// MARK: - Preview

#Preview("AppTextField States") {
    VStack(spacing: 20) {
        AppTextField(
            label: "Normal",
            placeholder: "you@company.com",
            text: .constant("")
        )
        AppTextField(
            label: "With Error",
            placeholder: "you@company.com",
            text: .constant("not-an-email"),
            errorMessage: "Enter a valid email address"
        )
        AppTextField(
            label: "Password",
            placeholder: "Min. 6 characters",
            text: .constant(""),
            isSecure: true
        )
    }
    .padding()
    .background(Color.appBackground)
}
