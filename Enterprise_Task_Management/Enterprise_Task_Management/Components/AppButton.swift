//
//  AppButton.swift
//  Enterprise_Task_Management
//
//  PURPOSE:
//  A single reusable button that covers every button variant in the app.
//  No more copy-pasting ZStack + RoundedRectangle + padding per screen.
//
//  KEY CONCEPT — Reusable Components:
//  Extract anything you write more than once into its own View.
//  The caller only specifies WHAT (title, style, action).
//  The component owns HOW it looks.
//
//  HOW TO USE:
//      AppButton(title: "Sign In") { viewModel.login() }
//      AppButton(title: "Delete", style: .destructive) { viewModel.delete() }
//      AppButton(title: "Cancel", style: .ghost) { dismiss() }
//      AppButton(title: "Saving…", isLoading: true) { }
//

import SwiftUI

// MARK: - AppButton

struct AppButton: View {

    // MARK: - Style Variants

    /// The four visual variants. Adding a new style only requires
    /// adding a case here + the color logic below — nothing else changes.
    enum Style {
        case primary      // filled brand color — for the main call-to-action
        case secondary    // outlined border    — for secondary actions
        case destructive  // filled red         — for delete / danger actions
        case ghost        // text only          — for subtle / tertiary actions
    }

    // MARK: - Properties

    let title: String
    var style: Style    = .primary
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    // MARK: - Computed Colors

    private var fillColor: Color {
        if isDisabled { return Color(uiColor: .systemGray5) }
        switch style {
        case .primary:     return .appPrimary
        case .secondary:   return .clear
        case .destructive: return .appError
        case .ghost:       return .clear
        }
    }

    private var labelColor: Color {
        if isDisabled { return .appTextTertiary }
        switch style {
        case .primary:     return .white
        case .secondary:   return .appPrimary
        case .destructive: return .white
        case .ghost:       return .appPrimary
        }
    }

    private var strokeColor: Color {
        style == .secondary ? .appPrimary : .clear
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            ZStack {
                // Background shape
                RoundedRectangle(cornerRadius: 12)
                    .fill(fillColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(strokeColor, lineWidth: 1.5)
                    )

                // Content: spinner while loading, label otherwise
                if isLoading {
                    ProgressView().tint(labelColor)
                } else {
                    Text(title)
                        .appFont(.headline)
                        .foregroundStyle(labelColor)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .disabled(isDisabled || isLoading)
        // Subtle press feedback via opacity
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("All Styles") {
    VStack(spacing: 12) {
        AppButton(title: "Sign In — primary")                            { }
        AppButton(title: "Cancel — secondary",     style: .secondary)   { }
        AppButton(title: "Delete — destructive",   style: .destructive) { }
        AppButton(title: "Skip — ghost",           style: .ghost)       { }
        AppButton(title: "Loading…",               isLoading: true)     { }
        AppButton(title: "Disabled",               isDisabled: true)    { }
    }
    .padding()
}
