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
    @Environment(\.modelContext) private var modelContext
    @State private var expenseToEdit: Expense?

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

            List {
                ForEach(groupedExpenses, id: \.0) { date, dailyExpenses in
                    Section {
                        ForEach(dailyExpenses, id: \.id) { expense in
                            Button(action: {
                                expenseToEdit = expense
                            }) {
                                transactionRow(
                                    icon: getCategoryIcon(expense.category),
                                    color: getCategoryColor(expense.category),
                                    name: expense.desc.isEmpty ? expense.category : expense.desc,
                                    amount: (expense.isExpense ? "-" : "+") + ReportFormat.rupiah(expense.amount),
                                    isExpense: expense.isExpense
                                )
                            }
                            .buttonStyle(.plain)
                            .listRowInsets(EdgeInsets()) // use our custom padding inside transactionRow
                            .listRowBackground(Theme.cardWhite)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteExpense(expense)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    } header: {
                        Text(headerDateFormatter.string(from: date))
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(Theme.textDark)
                            .textCase(nil)
                            .padding(.leading, -16) // offset default List inset slightly
                            .padding(.bottom, 4)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .padding(.bottom, 100)
            .sheet(item: Binding(
                get: { expenseToEdit },
                set: { expenseToEdit = $0 }
            )) { expense in
                AddExpenseManualView(expenseToEdit: expense)
            }
        }
        .navigationTitle("Record")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func deleteExpense(_ expense: Expense) {
        modelContext.delete(expense)
        try? modelContext.save()
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
