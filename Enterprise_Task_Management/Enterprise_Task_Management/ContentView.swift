//
//  ContentView.swift
//  Enterprise_Task_Management
//
//  Created by Sharmila Ganesan on 04/07/26.
//
//  PURPOSE:
//  Root entry point. Simply routes to the Login screen.
//  As the app grows (auth state persistence, splash screen, etc.)
//  this is where the routing logic will live.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        LoginView()
    }
}

#Preview {
    ContentView()
}
