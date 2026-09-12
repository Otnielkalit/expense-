//
//  expeneseApp.swift
//  expenese
//
//  Created by otnielkalit on 01/09/26.
//

import SwiftData
import SwiftUI
import AppIntents

@main
struct expeneseApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    let container: ModelContainer

    init() {
        container = try! ModelContainer(
            for: Expense.self, Category.self,
            configurations: ModelConfiguration(
                "expenese",
                cloudKitDatabase: .automatic
            )
        )
        AppDependencies.shared.container = container
        CategoryStore.seedDefaultsIfNeeded(context: container.mainContext)

        ExpeneseShortcuts.updateAppShortcutParameters()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}

final class AppDependencies {
    static let shared = AppDependencies()
    var container: ModelContainer?
}
