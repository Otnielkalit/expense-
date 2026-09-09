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
    @State private var draftPayload: DraftPayload?
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
        .sheet(item: $draftPayload) { payload in
            EditExpenseView(drafts: payload.items)
        }
    }

    private func handle(_ url: URL) {
        print("📂 URL received: \(url.absoluteString)")
        guard let incomingDrafts = VoiceDraftURL.decode(from: url), !incomingDrafts.isEmpty else {
            print("❌ Failed to decode URL or array is empty: \(url.absoluteString)")
            return
        }
        print("✅ Decoded \(incomingDrafts.count) drafts")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            draftPayload = DraftPayload(items: incomingDrafts)
        }
    }
}

#Preview {
    ContentView().modelContainer(for: Expense.self)
}
