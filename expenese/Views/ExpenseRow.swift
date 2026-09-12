//
//  ExpenseRow.swift
//  expenese
//
//  Created by otnielkalit on 02/09/26.
//

import SwiftData
import SwiftUI

struct ExpenseRow: View {
    let expense: Expense
    @Query(sort: \Category.sortOrder) private var categories: [Category]
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: CategoryCatalog.icon(for: expense.category, in: categories))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 34, height: 34)
                .background(CategoryCatalog.color(for: expense.category, in: categories))
                .clipShape(Circle())

            VStack(alignment: .leading) {
                Text(expense.desc)
                    .font(.headline)
                    .lineLimit(1)
                Text("\(CategoryCatalog.displayName(for: expense.category)) • \(expense.paymentMethod)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("Rp\(expense.amount.formatted())")
                .fontWeight(.semibold)
        }
    }
}
