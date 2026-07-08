//
//  AppColors.swift
//  Enterprise_Task_Management
//
//  PURPOSE:
//  Central color palette for the entire app.
//
//  KEY CONCEPT — Dark Mode:
//  iOS has two sets of "semantic" colors built in (e.g. UIColor.label,
//  UIColor.systemBackground). They automatically return the right value
//  for light OR dark mode — you write the color once, iOS handles the rest.
//
//  For CUSTOM brand colors that don't have a system equivalent, use
//  UIColor's dynamicProvider closure (see `appPrimary` below) to manually
//  specify a light value and a dark value.
//
//  HOW TO USE:
//      Text("Hello").foregroundStyle(.appPrimary)
//      view.background(Color.appBackground)
//

import SwiftUI

// MARK: - App Color Palette

extension Color {

    // ── Brand ──────────────────────────────────────────────────────────────
    //
    // Custom brand color — defined manually for both light and dark.
    // UIColor(dynamicProvider:) is called every time the system color scheme
    // changes, so the color always matches the current appearance.
    //
    static let appPrimary = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.47, green: 0.53, blue: 1.00, alpha: 1) // lighter indigo for dark bg
            : UIColor(red: 0.28, green: 0.24, blue: 0.90, alpha: 1) // deeper indigo for light bg
    })

    /// Soft tinted background for chips, badges, selected states.
    static let appPrimaryMuted = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.47, green: 0.53, blue: 1.00, alpha: 0.18)
            : UIColor(red: 0.28, green: 0.24, blue: 0.90, alpha: 0.10)
    })

    // ── Backgrounds ────────────────────────────────────────────────────────
    //
    // iOS semantic colors — no extra work needed for dark mode.
    // Light mode → white/light-grey.  Dark mode → black/dark-grey.
    //
    /// Main screen background.
    static let appBackground    = Color(uiColor: .systemBackground)

    /// Card / panel surface — one step above the background.
    static let appSurface       = Color(uiColor: .secondarySystemBackground)

    /// Elevated surface — modal sheets, popovers.
    static let appSurfaceRaised = Color(uiColor: .tertiarySystemBackground)

    // ── Text ───────────────────────────────────────────────────────────────

    /// High-emphasis: headings, primary body text.
    static let appTextPrimary   = Color(uiColor: .label)

    /// Medium-emphasis: subtitles, secondary info.
    static let appTextSecondary = Color(uiColor: .secondaryLabel)

    /// Low-emphasis: placeholders, disabled text.
    static let appTextTertiary  = Color(uiColor: .tertiaryLabel)

    // ── Status ─────────────────────────────────────────────────────────────
    //
    // These also adapt automatically — system green is brighter in dark mode
    // so it remains readable on dark backgrounds.
    //
    static let appSuccess       = Color(uiColor: .systemGreen)
    static let appWarning       = Color(uiColor: .systemOrange)
    static let appError         = Color(uiColor: .systemRed)

    // ── Separator ──────────────────────────────────────────────────────────

    /// Dividers and input borders.
    static let appBorder        = Color(uiColor: .separator)
}
