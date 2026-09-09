//
//  EditExpenseView.swift
//  expenese
//
//  Created by otnielkalit on 02/09/26.
//

import SwiftUI
import SwiftData

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
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "dollarsign.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.green)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Amount")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            TextField("0", text: $amountText)
                                .keyboardType(.numberPad)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section(header: Text("Transaction Details")) {
                    HStack {
                        Image(systemName: "tag.fill")
                            .foregroundColor(.blue)
                            .frame(width: 28)
                        Text("Category")
                        Spacer()
                        TextField("Category", text: $category)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "creditcard.fill")
                            .foregroundColor(.orange)
                            .frame(width: 28)
                        Text("Payment")
                        Spacer()
                        TextField("Payment Method", text: $paymentMethod)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.secondary)
                    }
                    
                    Picker(selection: $paymentType) {
                        ForEach(PaymentType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.left.arrow.right")
                                .foregroundColor(.purple)
                                .frame(width: 28)
                            Text("Type")
                        }
                    }
                }

                Section(header: Text("Notes")) {
                    HStack(alignment: .top) {
                        Image(systemName: "note.text")
                            .foregroundColor(.gray)
                            .frame(width: 28)
                            .padding(.top, 7)
                        
                        TextField("Add a description...", text: $desc, axis: .vertical)
                            .lineLimit(3...5)
                            .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Review Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .fontWeight(.bold)
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
