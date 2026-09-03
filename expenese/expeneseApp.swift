//
//  expeneseApp.swift
//  expenese
//
//  Created by otnielkalit on 01/09/26.
//

import SwiftData
import SwiftUI

@main
struct expeneseApp: App {
    let container: ModelContainer

    init() {
        container = try! ModelContainer(
            for: Expense.self,
            configurations: ModelConfiguration(
                "expenese",
                cloudKitDatabase: .automatic
            )
        )
        AppDependencies.shared.container = container
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}

/// Tempat nyimpan dependency yang di-share ke seluruh app & App Intent.
final class AppDependencies {
    static let shared = AppDependencies()
    var container: ModelContainer?
}
