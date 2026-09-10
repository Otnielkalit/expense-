//
//  ContentView.swift
//  expenese
//
//  Created by otnielkalit on 01/09/26.
//

import SwiftUI

enum AppTab {
    case home
    case input
    case report
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .home
    @State private var draftPayload: DraftPayload?
    let expeneseDidOpenURL = Notification.Name("ExpeneseDidOpenURL")

    var body: some View {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                TryVoiceView()
                    .tabItem {
                        Label("Input", systemImage: "plus")
                    }
                    .tag(1)
                Text("Report View")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Theme.bgBottom)
                    .tabItem {
                        Label("Report", systemImage: "chart.pie.fill")
                    }
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

    private var customTabBar: some View {
        HStack {
            TabBarButton(icon: "house.fill", title: "Home", isSelected: selectedTab == .home) {
                selectedTab = .home
            }
            Spacer()
            TabBarButton(icon: "plus", title: "Input", isSelected: selectedTab == .input) {
                selectedTab = .input
            }
            Spacer()
            TabBarButton(icon: "chart.pie.fill", title: "Report", isSelected: selectedTab == .report) {
                selectedTab = .report
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 12)
        .background(Theme.tabBarBg)
        .clipShape(Capsule())
        .padding(.horizontal, 40)
        .padding(.bottom, 20)
    }

    private func handle(_ url: URL) {
        guard let incomingDrafts = VoiceDraftURL.decode(from: url), !incomingDrafts.isEmpty else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            draftPayload = DraftPayload(items: incomingDrafts)
        }
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                Text(title)
                    .font(.system(size: 10, weight: .bold))
            }
            .foregroundColor(isSelected ? Theme.tabActive : .white)
        }
    }
}
