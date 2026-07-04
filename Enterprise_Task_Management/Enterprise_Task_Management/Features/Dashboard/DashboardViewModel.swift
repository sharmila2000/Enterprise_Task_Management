//
//  DashboardViewModel.swift
//  Enterprise_Task_Management
//
//  Created by Sharmila Ganesan on 04/07/26.
//
//  PURPOSE:
//  ViewModel for the Dashboard screen.
//  Fetches and manages the task list.
//  Shows how a ViewModel coordinates TWO injected repositories.
//

import Foundation
import Combine

// MARK: - DashboardViewModel

/// Drives the Dashboard screen.
///
/// Responsibilities:
/// - Fetch tasks from TaskRepository
/// - Filter/sort tasks based on user selection
/// - Provide task stats (total, completed, pending)
class DashboardViewModel: BaseViewModel {

    // MARK: - Output (observed by DashboardView)
    @Published var tasks: [TaskModel] = []
    @Published var selectedPriority: TaskPriority? = nil   // nil = show all
    @Published var showCompletedOnly: Bool = false

    // MARK: - Computed Stats (derived from tasks — no extra @Published needed)
    var totalCount: Int     { tasks.count }
    var completedCount: Int { tasks.filter(\.isCompleted).count }
    var pendingCount: Int   { tasks.filter { !$0.isCompleted }.count }

    /// The filtered list shown in the View.
    var filteredTasks: [TaskModel] {
        tasks.filter { task in
            let priorityMatch = selectedPriority == nil || task.priority == selectedPriority
            let completionMatch = !showCompletedOnly || task.isCompleted
            return priorityMatch && completionMatch
        }
    }

    // MARK: - Dependencies (injected via DI)
    private let taskRepository: TaskRepositoryProtocol
    private let authRepository: AuthenticationRepositoryProtocol

    // MARK: - Init
    init(
        taskRepository: TaskRepositoryProtocol,
        authRepository: AuthenticationRepositoryProtocol
    ) {
        self.taskRepository = taskRepository
        self.authRepository = authRepository
        super.init()
        loadTasks()
    }

    // MARK: - Actions

    /// Fetch all tasks from the repository.
    func loadTasks() {
        runTask {
            self.tasks = try await self.taskRepository.fetchAll()
        }
    }

    /// Toggle a task's completion status.
    func toggleCompletion(for task: TaskModel) {
        var updated = task
        updated.isCompleted.toggle()

        runTask {
            let saved = try await self.taskRepository.update(updated)
            // Replace the old task with the updated one in the local list
            if let index = self.tasks.firstIndex(where: { $0.id == saved.id }) {
                self.tasks[index] = saved
            }
        }
    }

    /// Delete a task.
    func delete(task: TaskModel) {
        runTask {
            try await self.taskRepository.delete(id: task.id)
            self.tasks.removeAll { $0.id == task.id }
        }
    }

    /// Filter by priority (pass nil to show all).
    func setFilter(priority: TaskPriority?) {
        selectedPriority = priority
    }

    /// Logged-in user's display name (from AuthRepository).
    var currentUserName: String {
        authRepository.currentUser()?.fullName ?? "User"
    }
}
