//
//  VoiceDraftURL.swift
//  expenese
//
//  Created by otnielkalit on 02/09/26.
//

import Foundation
import UIKit

enum VoiceDraftURL {
    private static let scheme = "expenese"
    private static let host = "editExpense"

    static func make(drafts: [Draft]) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host

        if let data = try? JSONEncoder().encode(drafts) {
            let base64String = data.base64EncodedString()
            components.queryItems = [URLQueryItem(name: "payload", value: base64String)]
        }

        return components.url
    }

    static func decode(from url: URL) -> [Draft]? {
        guard url.scheme == scheme, url.host == host,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let payload = components.queryItems?.first(where: { $0.name == "payload" })?.value,
              let data = Data(base64Encoded: payload) else {
            return nil
        }

        return try? JSONDecoder().decode([Draft].self, from: data)
    }
}

struct Draft: Identifiable, Codable {
    var id = UUID()
    var amount: Double
    var category: String
    var paymentMethod: String
    var paymentType: PaymentType
    var desc: String
    var date: Date
    var isExpense: Bool
}

struct DraftPayload: Identifiable {
    let id = UUID()
    var items: [Draft]
}

enum AppEnvironment {
    static func open(_ url: URL) async {
        await MainActor.run {
            NotificationCenter.default.post(
                name: Notification.Name("ExpeneseDidOpenURL"),
                object: nil,
                userInfo: ["url": url]
            )
            
            UIApplication.shared.open(url, options: [:]) { success in
                print("📂 AppEnvironment.open success: \(success) — \(url.absoluteString)")
            }
        }
    }
}
