//
//  ContentView.swift
//  expenese
//
//  Created by otnielkalit on 01/09/26.
//

import SwiftUI
import SwiftData

let expeneseDidOpenURL = Notification.Name("ExpeneseDidOpenURL")

struct ContentView: View {
    @State private var draft: Draft?
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
            handle(url)
        }
        .onReceive(NotificationCenter.default.publisher(for: expeneseDidOpenURL)) { note in
            if let url = note.userInfo?["url"] as? URL {
                handle(url)
            }
        }
        .sheet(item: $draft) { currentDraft in
            EditExpenseView(draft: currentDraft)
        }
    }

    private func handle(_ url: URL) {
        print("📂 URL received: \(url.absoluteString)")
        guard let incomingDraft = VoiceDraftURL.decode(from: url) else {
            print("❌ Failed to decode URL: \(url.absoluteString)")
            return
        }
        print("✅ Decoded draft: \(incomingDraft)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            draft = incomingDraft
        }
    }
}

#Preview {
    ContentView().modelContainer(for: Expense.self)
}
