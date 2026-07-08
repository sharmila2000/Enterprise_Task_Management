//
//  AppCard.swift
//  Enterprise_Task_Management
//
//  PURPOSE:
//  A container that applies the standard card look:
//  surface background + rounded corners + subtle shadow.
//
//  KEY CONCEPT — Generic View / @ViewBuilder:
//  `AppCard<Content: View>` accepts ANY SwiftUI content inside its braces,
//  just like HStack or VStack do. The `@ViewBuilder` attribute is what
//  enables that trailing-closure / multi-statement syntax.
//
//  HOW TO USE:
//      AppCard {
//          Text("Task title").appFont(.headline)
//          Text("Due tomorrow").appFont(.caption)
//      }
//
//      AppCard(padding: 0) {         // custom padding
//          Image(...)
//              .resizable()
//      }
//

import SwiftUI

// MARK: - AppCard

struct AppCard<Content: View>: View {

    // MARK: - Properties
    var padding: CGFloat = 16
    @ViewBuilder let content: Content   // accepts any View(s) inside the braces

    // MARK: - Body
    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.appSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            // Subtle shadow — small radius, very low opacity
            // so it looks natural in both light and dark mode
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview("AppCard") {
    VStack(spacing: 16) {

        AppCard {
            Text("Simple card with default padding")
                .appFont(.headline)
        }

        AppCard {
            VStack(alignment: .leading, spacing: 4) {
                Text("Fix login bug").appFont(.headline)
                Text("High priority · Due today")
                    .appFont(.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
    }
    .padding()
    .background(Color.appBackground)
}
