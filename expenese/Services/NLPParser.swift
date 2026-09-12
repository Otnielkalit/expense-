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
        var isExpense: Bool = true
    }
    
    static func parse(_ rawText: String, customCategories: [String] = []) -> [ParsedExpense] {
        let text = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let pattern = "(?i)(,(?!\\d)|\\.(?!\\d)|\\baku\\b|\\bsaya\\b|\\bterus\\b|\\bkemudian\\b|\\blalu\\b|\\bdan\\b|\\band\\b)"
        
        let splitText = text.replacingOccurrences(of: pattern, with: "|", options: .regularExpression)
        let rawChunks = splitText.components(separatedBy: "|")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            
        var expenses: [ParsedExpense] = []
        var lastDate: Date = .now
        var chunkBuffer = ""
        
        for chunk in rawChunks {
            let combinedText = chunkBuffer.isEmpty ? chunk : "\(chunkBuffer) \(chunk)"
            let (amount, _) = AmountParser.parse(from: combinedText)
            
            if amount == 0 {
                chunkBuffer = combinedText
                continue
            }
            
            let payment = PaymentMapper.match(in: combinedText)
            
            let lowerCombined = combinedText.lowercased()
            let incomeKeywords = ["gaji", "income", "pendapatan", "bonus", "dikasih", "dapat", "pemasukan"]
            let isIncome = incomeKeywords.contains(where: { lowerCombined.contains($0) })
            
            let category = isIncome ? "Income" : CategoryMapper.match(in: combinedText, customCategories: customCategories)
            let date = DateParser.parse(from: combinedText) ?? lastDate
            lastDate = date
            
            let description = combinedText.isEmpty ? "" : "\(combinedText) | Rp\(Int(amount).formatted())"
            
            expenses.append(ParsedExpense(
                amount: amount,
                category: category,
                paymentMethod: payment?.method ?? "Cash",
                paymentType: payment?.type ?? .cash,
                description: description,
                date: date,
                isExpense: !isIncome
            ))
            
            chunkBuffer = ""
        }
        
        if expenses.isEmpty {
            let lowerText = text.lowercased()
            let incomeKeywords = ["gaji", "income", "pendapatan", "bonus", "dikasih", "dapat", "pemasukan"]
            let isIncome = incomeKeywords.contains(where: { lowerText.contains($0) })
            let category = isIncome ? "Income" : CategoryMapper.match(in: text, customCategories: customCategories)
            
            expenses.append(ParsedExpense(
                amount: AmountParser.parse(from: text).amount,
                category: category,
                paymentMethod: PaymentMapper.match(in: text)?.method ?? "Cash",
                paymentType: PaymentMapper.match(in: text)?.type ?? .cash,
                description: text,
                date: DateParser.parse(from: text) ?? .now,
                isExpense: !isIncome
            ))
        }
        
        return expenses
    }
}
