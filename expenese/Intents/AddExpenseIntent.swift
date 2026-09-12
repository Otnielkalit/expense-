//
//  AddExpenseIntent.swift
//  expenese
//
//  Created by otnielkalit on 02/09/26.
//

import AppIntents
import SwiftUI
import SwiftData

struct AddExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Expense"
    static var openAppWhenRun: Bool = true

    @Parameter(title: "What did you spend on?")
    var speech: String

    func perform() async throws -> some IntentResult {
        let (customCategories, drafts, url) = await MainActor.run {
            var categories: [String] = []
            if let container = AppDependencies.shared.container {
                let context = ModelContext(container)
                let descriptor = FetchDescriptor<ExpenseCategory>()
                if let fetched = try? context.fetch(descriptor) {
                    categories = fetched.map { $0.name }
                }
            }
            
            let parsedList = NLPParser.parse(speech, customCategories: categories)
            let draftList = parsedList.map { parsed in
                Draft(
                    amount: parsed.amount,
                    category: parsed.category,
                    paymentMethod: parsed.paymentMethod,
                    paymentType: parsed.paymentType,
                    desc: parsed.description,
                    date: parsed.date,
                    isExpense: parsed.isExpense
                )
            }
            
            let u = VoiceDraftURL.make(drafts: draftList)
            return (categories, draftList, u)
        }
        
        guard let validUrl = url else {
            throw NSError(domain: "AddExpenseIntent", code: 1, userInfo: [NSLocalizedDescriptionKey: "Sorry, I couldn't process that."])
        }

        await AppEnvironment.open(validUrl)
        return .result()
    }
}