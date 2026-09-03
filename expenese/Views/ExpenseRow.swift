//
//  ExpenseRow.swift
//  expenese
//
//  Created by otnielkalit on 02/09/26.
//

import SwiftUI

struct ExpenseRow: View {
    let expense: Expense
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(expense.desc)
                    .font(.headline)
                    .lineLimit(1)
                Text("\(expense.category) • \(expense.paymentMethod)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("Rp\(expense.amount.formatted())")
                .fontWeight(.semibold)
        }
    }
}
