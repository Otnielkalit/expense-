//
//  Expense.swift
//  expenese
//
//  Created by otnielkalit on 02/09/26.
//

import Foundation
import SwiftData

@Model
final class Expense {
    var amount: Double
    var category: String
    var paymentMethod: String
    var paymentTypeRaw: String
    var desc: String
    var date: Date

    init(
        amount: Double,
        category: String,
        paymentMethod: String,
        paymentType: PaymentType,
        desc: String,
        date: Date = .now
    ) {
        self.amount = amount
        self.category = category
        self.paymentMethod = paymentMethod
        self.paymentTypeRaw = paymentType.rawValue
        self.desc = desc
        self.date = date
    }
}

extension Expense {
    var paymentType: PaymentType {
        get { PaymentType(rawValue: paymentTypeRaw) ?? .cash }
        set { paymentTypeRaw = newValue.rawValue }
    }
}
