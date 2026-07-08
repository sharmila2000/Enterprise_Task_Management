//
//  AppTypography.swift
//  Enterprise_Task_Management
//
//  PURPOSE:
//  A named type scale so every screen uses the same font sizes and weights.
//
//  KEY CONCEPT — Why a type scale?
//  Without it you scatter `.font(.title2.weight(.semibold))` everywhere.
//  If the designer changes section titles to .title3, you'd have to hunt
//  every screen. With a type scale you change ONE place → everywhere updates.
//
//  HOW TO USE:
//      Text("Dashboard").appFont(.displayTitle)
//      Text("Due today").appFont(.caption)
//

import SwiftUI

// MARK: - Type Scale

/// Every named text style used in the app.
/// Maps to SwiftUI's built-in Dynamic Type sizes so accessibility scaling
/// (larger text in Settings) works for free.
enum AppFont {
    case displayTitle  // 34 pt bold    — top-level screen headings
    case sectionTitle  // 22 pt semi    — section headers, card titles
    case headline      // 17 pt semi    — emphasized labels, row titles
    case body          // 17 pt regular — normal reading text
    case subhead       // 15 pt regular — secondary descriptions
    case caption       // 12 pt regular — hints, meta info
    case badge         // 11 pt semi    — chips, tags, status pills

    /// The resolved SwiftUI Font.
    var value: Font {
        switch self {
        case .displayTitle: return .largeTitle.weight(.bold)
        case .sectionTitle: return .title2.weight(.semibold)
        case .headline:     return .headline
        case .body:         return .body
        case .subhead:      return .subheadline
        case .caption:      return .caption
        case .badge:        return .caption2.weight(.semibold)
        }
    }
}

// MARK: - View Extension

extension View {
    /// Apply a named type-scale style to any View.
    ///
    /// Usage:
    /// ```swift
    /// Text("Sign In").appFont(.displayTitle)
    /// Text("you@company.com").appFont(.subhead)
    /// ```
    func appFont(_ style: AppFont) -> some View {
        self.font(style.value)
    }
}
