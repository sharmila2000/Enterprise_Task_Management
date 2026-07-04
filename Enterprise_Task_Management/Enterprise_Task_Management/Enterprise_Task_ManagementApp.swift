//
//  Enterprise_Task_ManagementApp.swift
//  Enterprise_Task_Management
//
//  Created by Sharmila Ganesan on 04/07/26.
//
//  PURPOSE:
//  The @main entry point of the app.
//  This is where the Dependency Injection Container is bootstrapped —
//  registering ALL app dependencies ONCE before any View is displayed.
//

import SwiftUI

@main
struct Enterprise_Task_ManagementApp: App {

    // MARK: - Init

    /// Called before the first scene is created.
    /// Perfect place to set up app-wide infrastructure.
    init() {
        // Bootstrap the DI Container.
        // All dependencies are registered here so every View and ViewModel
        // can resolve them via DIContainer.shared.resolve(...)
        DIContainer.shared.registerAppDependencies()
    }

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
