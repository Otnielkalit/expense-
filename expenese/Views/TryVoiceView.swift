//
//  TryVoiceView.swift
//  expenese
//
//  Created by otnielkalit on 02/09/26.
//

import SwiftUI
import SwiftData

struct TryVoiceView: View {
    @Environment(\.modelContext) private var context
    @State private var input = "meatballs 15000 pay with qris mandiri"
    @State private var result: NLPParser.ParsedExpense?

    var body: some View {
        Form {
            Section("Input") {
                TextField("Type something...", text: $input)
                    .textInputAutocapitalization(.never)
                Button("Simulate Siri Command") {
                    result = NLPParser.parse(input)
                }
            }

            if let result {
                Section("Parsed Result") {
                    LabeledContent("Amount", value: "Rp\(Int(result.amount))")
                    LabeledContent("Category", value: result.category)
                    LabeledContent("Payment", value: "\(result.paymentMethod) (\(result.paymentType.rawValue))")
                    Text(result.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section {
                    Button("Save Expense") {
                        let expense = Expense(
                            amount: result.amount,
                            category: result.category,
                            paymentMethod: result.paymentMethod,
                            paymentType: result.paymentType,
                            desc: result.description
                        )
                        context.insert(expense)
                        try? context.save()
                        self.result = nil
                        input = ""
                    }
                }
            }
        }
        .navigationTitle("Try Voice")
    }
}
