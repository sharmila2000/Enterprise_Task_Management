//
//  DashboardView.swift
//  Enterprise_Task_Management
//
//  Created by Sharmila Ganesan on 04/07/26.
//
//  PURPOSE:
//  The Dashboard screen — shown after a successful login.
//  Uses AppCard, theme colors (.appPrimary, .appWarning…)
//  and theme fonts (.appFont) throughout.
//

import SwiftUI

// MARK: - DashboardView

struct DashboardView: View {

    // MARK: - ViewModel (resolved from DI)
    @StateObject private var viewModel = DashboardViewModel(
        taskRepository: DIContainer.shared.resolve(TaskRepositoryProtocol.self),
        authRepository: DIContainer.shared.resolve(AuthenticationRepositoryProtocol.self)
    )

    // MARK: - Body
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()   // ← theme background

            VStack(spacing: 0) {
                statsBar
                    .padding(.horizontal)
                    .padding(.top, 12)

                filterBar
                    .padding(.horizontal)
                    .padding(.vertical, 10)

                if viewModel.filteredTasks.isEmpty && !viewModel.isLoading {
                    emptyState
                } else {
                    taskList
                }
            }

            if viewModel.isLoading { loadingOverlay }
        }
        .navigationTitle("Hello, \(viewModel.currentUserName.components(separatedBy: " ").first ?? "👋")")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { viewModel.loadTasks() } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundStyle(Color.appPrimary)   // ← theme color
                }
            }
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.hasError },
            set: { if !$0 { viewModel.clearError() } }
        )) {
            Button("OK") { viewModel.clearError() }
            Button("Retry") { viewModel.loadTasks() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Subviews

    // AppCard wraps the stats row — surface background + shadow for free
    private var statsBar: some View {
        AppCard(padding: 12) {
            HStack(spacing: 0) {
                StatCard(value: viewModel.totalCount,     label: "Total",     color: .appPrimary)
                StatCard(value: viewModel.pendingCount,   label: "Pending",   color: .appWarning)
                StatCard(value: viewModel.completedCount, label: "Completed", color: .appSuccess)
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(label: "All", isSelected: viewModel.selectedPriority == nil) {
                    viewModel.setFilter(priority: nil)
                }
                ForEach(TaskPriority.allCases, id: \.self) { priority in
                    FilterChip(label: priority.rawValue, isSelected: viewModel.selectedPriority == priority) {
                        viewModel.setFilter(priority: priority)
                    }
                }
            }
        }
    }

    private var taskList: some View {
        List {
            ForEach(viewModel.filteredTasks) { task in
                TaskRow(task: task) { viewModel.toggleCompletion(for: task) }
            }
            .onDelete { indexSet in
                indexSet.forEach { viewModel.delete(task: viewModel.filteredTasks[$0]) }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)   // let appBackground show through
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No Tasks",
            systemImage: "checklist",
            description: Text("All tasks are hidden by the current filter.")
        )
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.15).ignoresSafeArea()
            ProgressView("Loading tasks...")
                .padding(20)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - Private Subviews
// These are small, single-purpose views only used by DashboardView,
// so they live in the same file to keep things easy to find.

private struct StatCard: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .appFont(.sectionTitle)         // ← theme font
                .foregroundStyle(color)
            Text(label)
                .appFont(.caption)              // ← theme font
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
    }
}

private struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .appFont(isSelected ? .headline : .subhead)  // ← theme font
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isSelected ? Color.appPrimaryMuted : Color.appSurface)
                .foregroundStyle(isSelected ? Color.appPrimary : Color.appTextSecondary)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(isSelected ? Color.appPrimary : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct TaskRow: View {
    let task: TaskModel
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isCompleted ? Color.appSuccess : Color.appTextTertiary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .appFont(.headline)         // ← theme font
                    .strikethrough(task.isCompleted, color: .appTextTertiary)
                    .foregroundStyle(task.isCompleted ? Color.appTextSecondary : Color.appTextPrimary)

                if !task.description.isEmpty {
                    Text(task.description)
                        .appFont(.caption)      // ← theme font
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()
            PriorityBadge(priority: task.priority)
        }
        .padding(.vertical, 4)
    }
}

private struct PriorityBadge: View {
    let priority: TaskPriority

    // Each priority maps to a theme status color
    var color: Color {
        switch priority {
        case .high:   return .appError
        case .medium: return .appWarning
        case .low:    return .appSuccess
        }
    }

    var body: some View {
        Text(priority.rawValue)
            .appFont(.badge)                    // ← theme font
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview("Light") {
    NavigationStack { DashboardView() }
}

#Preview("Dark") {
    NavigationStack { DashboardView() }
        .preferredColorScheme(.dark)            // ← test dark mode
}
