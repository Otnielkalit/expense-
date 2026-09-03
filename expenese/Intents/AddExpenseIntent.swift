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

    /// Siri menangkap seluruh kalimat user di sini.
    @Parameter(title: "What did you spend on?")
    var speech: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Parse teks
        let parsed = NLPParser.parse(speech)

        // JANGAN simpan langsung. Buka app dengan data draft yang bisa dikoreksi.
        // Encode data agar aman untuk URL.
        guard let url = VoiceDraftURL.make(
            amount: parsed.amount,
            category: parsed.category,
            paymentMethod: parsed.paymentMethod,
            paymentType: parsed.paymentType.rawValue,
            desc: parsed.description
        ) else {
            return .result(dialog: "Sorry, I couldn't process that.")
        }

        // Buka app lewat custom URL scheme.
        await AppEnvironment.open(url)

        return .result(
            dialog: "Opened the app to review your expense."
        )
    }
}
