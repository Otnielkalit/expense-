//
//  HistoryView.swift
//  expenese
//
//  Created by otnielkalit on 02/09/26.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \Expense.date, order: .reverse)
    private var expenses: [Expense]
    
    var body: some View {
        List {
            ForEach(expenses) { expense in
                ExpenseRow(expense: expense)
            }
        }
        .navigationTitle("History")
    }
}
