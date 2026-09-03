//
//  NLPParser.swift
//  expenese
//
//  Created by otnielkalit on 02/09/26.
//

import Foundation

enum NLPParser {
    struct ParsedExpense {
        var amount: Double = 0
        var category: String = "Other"
        var paymentMethod: String = "Cash"
        var paymentType: PaymentType = .cash
        var description: String = ""
        var date: Date = .now
    }
    
    static func parse(_ rawText: String) -> ParsedExpense {
        let text = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let (amount, _) = AmountParser.parse(from: text)
        
        let payment = PaymentMapper.match(in: text)
        
        let category = CategoryMapper.match(in: text)
        
        let description = "\(text) | Rp\(Int(amount).formatted())"
        
        return ParsedExpense(
            amount: amount,
            category: category,
            paymentMethod: payment?.method ?? "Cash",
            paymentType: payment?.type ?? .cash,
            description: description,
            date: .now
        )
    }
}
