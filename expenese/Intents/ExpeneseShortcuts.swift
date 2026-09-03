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
                "Add expense on \(.applicationName)"
            ]
        )
    }
}
