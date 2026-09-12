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
    var amount: Double = 0.0
    var category: String = ""
    var paymentMethod: String = ""
    var paymentTypeRaw: String = ""
    var desc: String = ""
    var date: Date = Date()
    var isExpense: Bool = true

    init(
        amount: Double = 0.0,
        category: String = "",
        paymentMethod: String = "",
        paymentType: PaymentType = .cash,
        desc: String = "",
        date: Date = .now,
        isExpense: Bool = true
    ) {
        self.amount = amount
        self.category = category
        self.paymentMethod = paymentMethod
        self.paymentTypeRaw = paymentType.rawValue
        self.desc = desc
        self.date = date
        self.isExpense = isExpense
    }
}

extension Expense {
    var paymentType: PaymentType {
        get { PaymentType(rawValue: paymentTypeRaw) ?? .cash }
        set { paymentTypeRaw = newValue.rawValue }
    }
}
