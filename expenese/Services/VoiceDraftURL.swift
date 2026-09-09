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

    static func make(
        amount: Double,
        category: String,
        paymentMethod: String,
        paymentType: String,
        desc: String
    ) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host

        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "amount", value: String(amount)))
        queryItems.append(URLQueryItem(name: "category", value: category))
        queryItems.append(URLQueryItem(name: "payment", value: paymentMethod))
        queryItems.append(URLQueryItem(name: "type", value: paymentType))
        queryItems.append(URLQueryItem(name: "desc", value: desc))
        components.queryItems = queryItems

        return components.url
    }

    static func decode(from url: URL) -> Draft? {
        guard url.scheme == scheme, url.host == host,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let items = components.queryItems else {
            return nil
        }

        func value(_ name: String) -> String? {
            items.first(where: { $0.name == name })?.value
        }

        let amount = Double(value("amount") ?? "") ?? 0
        let category = value("category") ?? "Other"
        let paymentMethod = value("payment") ?? "Cash"
        let paymentType = PaymentType(rawValue: value("type") ?? "") ?? .cash
        let desc = value("desc") ?? ""

        return Draft(
            amount: amount,
            category: category,
            paymentMethod: paymentMethod,
            paymentType: paymentType,
            desc: desc
        )
    }
}

struct Draft: Identifiable {
    let id = UUID()
    var amount: Double
    var category: String
    var paymentMethod: String
    var paymentType: PaymentType
    var desc: String
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
