//
//  TaskRepository.swift
//  Enterprise_Task_Management
//
//  Created by Sharmila Ganesan on 04/07/26.
//
//  PURPOSE:
//  Concrete repository for Task data operations.
//  Implements TaskRepositoryProtocol — the contract ViewModels depend on.
//  Uses APIClient to communicate with the backend.
//
//  NOTE: Business logic is minimal here intentionally.
//  Full CRUD implementation comes in a future task when we build the Task feature.
//

import Foundation

// MARK: - TaskModel

/// The Task data model (plain Swift struct — no UI dependencies).
///
/// Identifiable: needed for SwiftUI ForEach
/// Codable: needed for JSON encode/decode with the API
struct TaskModel: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var isCompleted: Bool
    var priority: TaskPriority
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        isCompleted: Bool = false,
        priority: TaskPriority = .medium,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.priority = priority
        self.createdAt = createdAt
    }
}

// MARK: - TaskPriority

enum TaskPriority: String, Codable, CaseIterable {
    case low    = "Low"
    case medium = "Medium"
    case high   = "High"

    var color: String {        // used in SwiftUI via Color(named:) or switch
        switch self {
        case .low:    return "green"
        case .medium: return "orange"
        case .high:   return "red"
        }
    }
}

// MARK: - TaskRepositoryProtocol

/// The contract that defines what task data operations are available.
/// ViewModels depend on this protocol — NOT on TaskRepository directly.
///
/// This allows us to inject a MockTaskRepository in unit tests
/// without touching any networking code.
protocol TaskRepositoryProtocol {
    func fetchAll() async throws -> [TaskModel]
    func fetchById(_ id: UUID) async throws -> TaskModel?
    func create(_ task: TaskModel) async throws -> TaskModel
    func update(_ task: TaskModel) async throws -> TaskModel
    func delete(id: UUID) async throws
}

// MARK: - TaskRepository

/// Concrete implementation of TaskRepositoryProtocol.
/// Talks to the backend via APIClient.
///
/// Future tasks will fill in the real API endpoint paths.
final class TaskRepository: BaseRepository<TaskModel>, TaskRepositoryProtocol {

    // MARK: - Dependencies
    private let apiClient: APIClient

    // MARK: - Init
    init(apiClient: APIClient) {
        self.apiClient = apiClient
        super.init()
        log("TaskRepository initialized")
    }

    // MARK: - TaskRepositoryProtocol

    func fetchAll() async throws -> [TaskModel] {
        log("Fetching all tasks...")
        // TODO (future task): return try await apiClient.request(APIEndpoint(path: "/tasks", method: .GET))

        // Stub: return sample data until the API is ready
        return TaskModel.sampleData
    }

    func fetchById(_ id: UUID) async throws -> TaskModel? {
        log("Fetching task \(id)...")
        // TODO: return try await apiClient.request(APIEndpoint(path: "/tasks/\(id)", method: .GET))
        return TaskModel.sampleData.first { $0.id == id }
    }

    func create(_ task: TaskModel) async throws -> TaskModel {
        log("Creating task: \(task.title)")
        // TODO: return try await apiClient.request(APIEndpoint(path: "/tasks", method: .POST, body: task))
        return task
    }

    func update(_ task: TaskModel) async throws -> TaskModel {
        log("Updating task: \(task.id)")
        // TODO: return try await apiClient.request(APIEndpoint(path: "/tasks/\(task.id)", method: .PUT, body: task))
        return task
    }

    func delete(id: UUID) async throws {
        log("Deleting task: \(id)")
        // TODO: try await apiClient.send(APIEndpoint(path: "/tasks/\(id)", method: .DELETE))
    }
}

// MARK: - Sample Data (for development / previews)

extension TaskModel {
    static let sampleData: [TaskModel] = [
        TaskModel(title: "Set up MVVM architecture",   description: "BaseViewModel, BaseRepository, DIContainer", isCompleted: true,  priority: .high),
        TaskModel(title: "Build Login screen",          description: "Email + password authentication flow",       isCompleted: false, priority: .high),
        TaskModel(title: "Build Dashboard screen",      description: "Task list with filter and sort",             isCompleted: false, priority: .medium),
        TaskModel(title: "Add CoreData persistence",    description: "Offline-first data layer",                   isCompleted: false, priority: .medium),
        TaskModel(title: "Write unit tests",            description: "ViewModels and Repositories",                isCompleted: false, priority: .low)
    ]
}
