//
//  AddExpenseIntent.swift
//  expenese
//
//  Created by otnielkalit on 02/09/26.
//

import AppIntents
import SwiftUI

struct AddExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Expense"
    static var openAppWhenRun: Bool = true

    @Parameter(title: "What did you spend on?")
    var speech: String

    func perform() async throws -> some IntentResult {
        let parsedList = NLPParser.parse(speech)
        let drafts = parsedList.map { parsed in
            Draft(
                amount: parsed.amount,
                category: parsed.category,
                paymentMethod: parsed.paymentMethod,
                paymentType: parsed.paymentType,
                desc: parsed.description,
                date: parsed.date
            )
        }
        
        guard let url = VoiceDraftURL.make(drafts: drafts) else {
            throw NSError(domain: "AddExpenseIntent", code: 1, userInfo: [NSLocalizedDescriptionKey: "Sorry, I couldn't process that."])
        }

        await AppEnvironment.open(url)
        return .result()
    }
}