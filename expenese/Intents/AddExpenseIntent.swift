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
        let parsed = NLPParser.parse(speech)
        guard let url = VoiceDraftURL.make(
            amount: parsed.amount,
            category: parsed.category,
            paymentMethod: parsed.paymentMethod,
            paymentType: parsed.paymentType.rawValue,
            desc: parsed.description
        ) else {
            throw NSError(domain: "AddExpenseIntent", code: 1, userInfo: [NSLocalizedDescriptionKey: "Sorry, I couldn't process that."])
        }

        // Karena `openAppWhenRun = true`, app sudah dipanggil ke foreground.
        // Buka URL scheme dari dalam proses aplikasi.
        await AppEnvironment.open(url)
        return .result()
    }
}
