//
//  VoiceDraftURL.swift
//  expenese
//
//  Created by otnielkalit on 02/09/26.
//

import Foundation
import UIKit

/// Membuat URL scheme untuk membawa data draft hasil parse dari Siri ke app.
enum VoiceDraftURL {
    private static let scheme = "expenese"
    private static let host = "editExpense"

    /// Encode data expense menjadi URL: expenese://editExpense?amount=..&category=..&payment=..&type=..&desc=..
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

    /// Decode data dari URL menjadi draft expense yang siap dikoreksi.
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

/// Representasi data yang sedang menunggu dikoreksi user.
struct Draft {
    var amount: Double
    var category: String
    var paymentMethod: String
    var paymentType: PaymentType
    var desc: String
}

/// Helper kecil untuk membuka URL biar gampang di-test/dimock.
enum AppEnvironment {
    static func open(_ url: URL) async {
        await MainActor.run {
            UIApplication.shared.open(url)
        }
    }
}
