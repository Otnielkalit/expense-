//
//  SettingsView.swift
//  expenese
//
//  Created by otnielkalit on 12/09/26.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var showingClearDataAlert = false
    @State private var showSyncSuccess = false

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Data Management")) {
                    Button(action: {
                        showSyncSuccess = true
                        try? modelContext.save()
                    }) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath.icloud.fill")
                                .foregroundColor(.blue)
                            Text("Sync to iCloud")
                                .foregroundColor(.primary)
                            Spacer()
                            if showSyncSuccess {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }

                    Button(role: .destructive, action: {
                        showingClearDataAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Clear All Data")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Clear All Data", isPresented: $showingClearDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("Are you sure you want to delete all expenses and custom categories? This action cannot be undone.")
            }
        }
    }
    
    private func clearAllData() {
        do {
            try modelContext.delete(model: Expense.self)
            try modelContext.delete(model: Category.self)
            try modelContext.save()
        } catch {
            print("Failed to clear data: \(error.localizedDescription)")
        }
    }
}

#Preview {
    SettingsView()
}
