//
//  ContentView.swift
//  expenese
//
//  Created by otnielkalit on 01/09/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var draft: Draft?
    @State private var showEditor = false
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            TryVoiceView()
                .tabItem { Label("Try Voice", systemImage: "mic.fill") }
                .tag(1)

            HistoryView()
                .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
                .tag(2)
        }
        .onOpenURL { url in
            if let incomingDraft = VoiceDraftURL.decode(from: url) {
                draft = incomingDraft
                showEditor = true
            }
        }
        .sheet(isPresented: $showEditor, onDismiss: { draft = nil }) {
            if let draft {
                EditExpenseView(draft: draft)
            }
        }
    }
}

#Preview {
    ContentView().modelContainer(for: Expense.self)
}
