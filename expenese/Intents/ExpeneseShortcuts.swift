//
//  ExpeneseShortcuts.swift
//  expenese
//
//  Created by otnielkalit on 02/09/26.
//


import AppIntents

struct ExpeneseShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddExpenseIntent(),
            phrases: [
                "Add expense in \(.applicationName)",
                "Log expense with \(.applicationName)",
                "Add a new expense on \(.applicationName)"
            ],
            shortTitle: "Add Expense",
            systemImageName: "plus.circle"
        )
    }
}
