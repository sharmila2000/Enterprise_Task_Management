//
//  DashboardView.swift
//  Enterprise_Task_Management
//
//  Created by Sharmila Ganesan on 04/07/26.
//
//  PURPOSE:
//  The Dashboard screen — shown after a successful login.
//  Displays the task list with stats and filter controls.
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
            VStack(spacing: 0) {

                // ── Stats Bar ─────────────────────────────────────────
                statsBar
                    .padding()
                    .background(Color(.systemGroupedBackground))

                // ── Priority Filter ───────────────────────────────────
                filterBar
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                // ── Task List ─────────────────────────────────────────
                if viewModel.filteredTasks.isEmpty && !viewModel.isLoading {
                    emptyState
                } else {
                    taskList
                }
            }

            // ── Loading Overlay ───────────────────────────────────────
            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .navigationTitle("Hello, \(viewModel.currentUserName.components(separatedBy: " ").first ?? "👋")")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)    // can't go back to login once authenticated
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.loadTasks()
                } label: {
                    Image(systemName: "arrow.clockwise")
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

    private var statsBar: some View {
        HStack(spacing: 0) {
            StatCard(value: viewModel.totalCount,     label: "Total",     color: .blue)
            StatCard(value: viewModel.pendingCount,   label: "Pending",   color: .orange)
            StatCard(value: viewModel.completedCount, label: "Completed", color: .green)
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    label: "All",
                    isSelected: viewModel.selectedPriority == nil,
                    color: .blue
                ) {
                    viewModel.setFilter(priority: nil)
                }

                ForEach(TaskPriority.allCases, id: \.self) { priority in
                    FilterChip(
                        label: priority.rawValue,
                        isSelected: viewModel.selectedPriority == priority,
                        color: .orange
                    ) {
                        viewModel.setFilter(priority: priority)
                    }
                }
            }
        }
    }

    private var taskList: some View {
        List {
            ForEach(viewModel.filteredTasks) { task in
                TaskRow(task: task) {
                    viewModel.toggleCompletion(for: task)
                }
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    viewModel.delete(task: viewModel.filteredTasks[index])
                }
            }
        }
        .listStyle(.plain)
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

// MARK: - Reusable Subviews

private struct StatCard: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.title2).fontWeight(.bold)
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

private struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isSelected ? color.opacity(0.15) : Color(.systemGray5))
                .foregroundStyle(isSelected ? color : .secondary)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(isSelected ? color : Color.clear, lineWidth: 1)
                )
        }
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
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .fontWeight(.medium)
                    .strikethrough(task.isCompleted, color: .secondary)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)

                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
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

    var color: Color {
        switch priority {
        case .high:   return .red
        case .medium: return .orange
        case .low:    return .green
        }
    }

    var body: some View {
        Text(priority.rawValue)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        DashboardView()
    }
}
