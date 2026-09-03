//
//  EditExpenseView.swift
//  expenese
//
//  Created by otnielkalit on 02/09/26.
//

import SwiftUI
import SwiftData

/// Form preview hasil voice yang bisa dikoreksi sebelum disimpan.
struct EditExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    let draft: Draft

    @State private var amountText: String
    @State private var category: String
    @State private var paymentMethod: String
    @State private var paymentType: PaymentType
    @State private var desc: String

    init(draft: Draft) {
        self.draft = draft
        _amountText = State(initialValue: String(Int(draft.amount)))
        _category = State(initialValue: draft.category)
        _paymentMethod = State(initialValue: draft.paymentMethod)
        _paymentType = State(initialValue: draft.paymentType)
        _desc = State(initialValue: draft.desc)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Detail") {
                    TextField("Amount", text: $amountText)
                        .keyboardType(.numberPad)
                    TextField("Category", text: $category)
                    TextField("Payment Method", text: $paymentMethod)
                }

                Section("Payment Type") {
                    Picker("Type", selection: $paymentType) {
                        ForEach(PaymentType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }

                Section("Full Text") {
                    TextField("Description", text: $desc, axis: .vertical)
                        .lineLimit(3...5)
                }

                Section {
                    Button("Save Expense") {
                        save()
                    }
                }
            }
            .navigationTitle("Review Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func save() {
        let expense = Expense(
            amount: Double(amountText) ?? 0,
            category: category,
            paymentMethod: paymentMethod,
            paymentType: paymentType,
            desc: desc
        )
        context.insert(expense)
        try? context.save()
        dismiss()
    }
}
