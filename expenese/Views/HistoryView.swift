//
//  HistoryView.swift
//  expenese
//
//  Created by otnielkalit on 02/09/26.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Query private var customCategories: [Category]
    @Environment(\.dismiss) private var dismiss

    var groupedExpenses: [(Date, [Expense])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: expenses) { expense in
            calendar.startOfDay(for: expense.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }

    private let headerDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd MMMM yyyy"
        return formatter
    }()

    var body: some View {
        ZStack(alignment: .top) {
            Theme.bgApp.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    ForEach(groupedExpenses, id: \.0) { date, dailyExpenses in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(headerDateFormatter.string(from: date))
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(Theme.textDark)
                                .padding(.horizontal, 24)

                            VStack(spacing: 0) {
                                ForEach(Array(dailyExpenses.enumerated()), id: \.element.id) { index, expense in
                                    transactionRow(
                                        icon: getCategoryIcon(expense.category),
                                        color: getCategoryColor(expense.category),
                                        name: expense.desc.isEmpty ? expense.category : expense.desc,
                                        amount: (expense.isExpense ? "-" : "+") + ReportFormat.rupiah(expense.amount),
                                        isExpense: expense.isExpense
                                    )
                                    if index < dailyExpenses.count - 1 {
                                        Divider().padding(.horizontal, 16)
                                    }
                                }
                            }
                            .background(Theme.cardWhite)
                            .cornerRadius(20)
                            .shadow(color: .gray.opacity(0.05), radius: 10, y: 5)
                            .padding(.horizontal, 24)
                        }
                    }
                }
                .padding(.top, 24)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func transactionRow(icon: String, color: Color, name: String, amount: String, isExpense: Bool = true) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(color)
                .clipShape(Circle())
            
            Text(name)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Theme.textDark)
            
            Spacer()
            
            Text(amount)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(isExpense ? Theme.expenseRed : Theme.incomePurple)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }

    private func getCategoryIcon(_ name: String) -> String {
        if let custom = customCategories.first(where: { $0.name == name }) { return custom.icon }
        return CategoryStyle.icon(for: name)
    }
    
    private func getCategoryColor(_ name: String) -> Color {
        if let custom = customCategories.first(where: { $0.name == name }) { return Color(hex: custom.colorHex) }
        return CategoryStyle.color(for: name)
    }
}
