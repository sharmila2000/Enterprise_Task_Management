//
//  DIContainer.swift
//  Enterprise_Task_Management
//
//  Created by Sharmila Ganesan on 04/07/26.
//
//  PURPOSE:
//  The single source of truth for creating and distributing dependencies.
//  Instead of classes creating their own dependencies (tight coupling),
//  they ask the container for what they need (loose coupling).
//
//  CONCEPTS DEMONSTRATED:
//  - Dependency Injection (DI): Provide dependencies from outside, not inside.
//  - Inversion of Control (IoC): High-level modules don't depend on low-level ones.
//  - Singleton Pattern: One shared container for the whole app.
//  - Factory vs Singleton registration: New instance vs reused instance.
//

import Foundation

// MARK: - Resolver Protocol

/// Defines the minimum interface for resolving registered types.
/// Having this as a protocol means you can create a MockResolver in tests.
protocol Resolver {
    func resolve<T>(_ type: T.Type) -> T
}

// MARK: - DIContainer

/// The app-wide Dependency Injection Container.
///
/// **What is Dependency Injection?**
/// Instead of a class creating its own dependencies:
/// ```swift
/// // ❌ Tight coupling — hard to test, hard to change
/// class TaskViewModel {
///     let repository = TaskRepository()   // creates its own
/// }
/// ```
/// We inject the dependency from outside:
/// ```swift
/// // ✅ Loose coupling — easy to swap with a mock in tests
/// class TaskViewModel {
///     let repository: TaskRepositoryProtocol   // injected
///     init(repository: TaskRepositoryProtocol) { self.repository = repository }
/// }
/// ```
/// The DIContainer automates this injection process.
///
/// **Registration (write once at startup):**
/// ```swift
/// DIContainer.shared.register(TaskRepositoryProtocol.self) {
///     TaskRepository()
/// }
/// ```
///
/// **Resolution (use anywhere):**
/// ```swift
/// let repo: TaskRepositoryProtocol = DIContainer.shared.resolve(TaskRepositoryProtocol.self)
/// ```
final class DIContainer: Resolver {

    // MARK: - Singleton

    /// The one shared container for the entire app.
    /// Accessed as `DIContainer.shared` everywhere.
    static let shared = DIContainer()

    // MARK: - Storage

    /// Dictionary mapping type names → factory closures.
    /// Using `[String: () -> Any]` so we can store any type without generics issues.
    private var factories: [String: () -> Any] = [:]

    // MARK: - Init (private to enforce singleton)
    private init() {}

    // MARK: - Registration

    /// Register a **factory**: creates a NEW instance every time `resolve` is called.
    ///
    /// Use this for ViewModels, which should be fresh each time.
    ///
    /// ```swift
    /// DIContainer.shared.register(HomeViewModel.self) { HomeViewModel() }
    /// ```
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        factories[key] = factory
        log("📦 Registered factory → \(key)")
    }

    /// Register a **singleton**: reuses the SAME instance every time `resolve` is called.
    ///
    /// Use this for services and repositories that are stateless and expensive to create.
    ///
    /// ```swift
    /// DIContainer.shared.registerSingleton(NetworkService.self, instance: NetworkService())
    /// ```
    func registerSingleton<T>(_ type: T.Type, instance: T) {
        let key = String(describing: type)
        factories[key] = { instance }      // closure always returns the same captured instance
        log("♻️  Registered singleton → \(key)")
    }

    // MARK: - Resolution

    /// Resolve (retrieve) a registered dependency.
    ///
    /// ⚠️ This will **crash** (fatalError) if the type was never registered.
    /// This is intentional: fail-fast during development catches missing
    /// registrations immediately rather than silently producing wrong behavior.
    ///
    /// ```swift
    /// let repo: TaskRepositoryProtocol = DIContainer.shared.resolve(TaskRepositoryProtocol.self)
    /// ```
    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        guard let factory = factories[key], let resolved = factory() as? T else {
            fatalError("""

            ❌ DIContainer: Cannot resolve '\(key)'.
            ─────────────────────────────────────────
            Did you forget to register it?
            → Add this to DIContainer.registerAppDependencies():
               register(\(key).self) { /* your implementation */ }
            ─────────────────────────────────────────
            """)
        }
        log("✅ Resolved → \(key)")
        return resolved
    }

    /// Safely attempt to resolve a dependency.
    /// Returns `nil` instead of crashing if the type is not registered.
    ///
    /// Use this for optional features that may or may not be configured.
    func resolveOptional<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        return factories[key]?() as? T
    }

    // MARK: - App Bootstrap

    /// Register all global app dependencies here.
    ///
    /// Called ONCE from `@main` App struct `init()`.
    /// **Order matters** — register dependencies before the things that depend on them.
    func registerAppDependencies() {
        log("🚀 Registering app dependencies...")

        // ── Step 1: Networking ─────────────────────────────────────────
        // Singleton: one shared APIClient for the whole app
        registerSingleton(APIClient.self, instance: APIClient())

        // ── Step 2: Repositories ───────────────────────────────────────
        // Singletons: repositories are stateless & expensive to create
        registerSingleton(
            AuthenticationRepositoryProtocol.self,
            instance: AuthenticationRepository(
                apiClient: resolve(APIClient.self)
            )
        )
        registerSingleton(
            TaskRepositoryProtocol.self,
            instance: TaskRepository(
                apiClient: resolve(APIClient.self)
            )
        )

        // ── Step 3: ViewModels ─────────────────────────────────────────
        // Factories: ViewModels are created fresh per screen
        register(LoginViewModel.self) {
            LoginViewModel(authRepository: self.resolve(AuthenticationRepositoryProtocol.self))
        }
        register(DashboardViewModel.self) {
            DashboardViewModel(
                taskRepository: self.resolve(TaskRepositoryProtocol.self),
                authRepository: self.resolve(AuthenticationRepositoryProtocol.self)
            )
        }

        log("✅ All dependencies registered successfully.")
    }

    // MARK: - Debug Helpers

    /// List all registered type keys (useful for debugging).
    var registeredKeys: [String] {
        Array(factories.keys).sorted()
    }

    // MARK: - Private Logging

    private func log(_ message: String) {
        #if DEBUG
        print("🔧 [DIContainer] \(message)")
        #endif
    }
}
