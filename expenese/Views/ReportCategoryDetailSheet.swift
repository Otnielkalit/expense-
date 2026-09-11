//
//  ReportCategoryDetailSheet.swift
//  expenese
//
//  Created by Marzandi Zahran Affandi Leta on 11/09/26.
//

import SwiftUI

struct ReportCategoryDetailSheet: View {
    let category: ReportCategoryItem
    let expenses: [ReportDummyExpense]

    private var totalAmount: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    headerCard
                    Text("Transactions")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.top, 4)

                    VStack(spacing: 10) {
                        ForEach(expenses) { expense in
                            transactionRow(expense)
                        }
                    }
                }
                .padding(20)
            }
            .background(Color.white)
            .navigationTitle(category.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var headerCard: some View {
        HStack(spacing: 14) {
            Image(systemName: category.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(category.color)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text("\(expenses.count) transactions")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Text(ReportFormat.rupiahFull(totalAmount))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
            }

            Spacer()
        }
        .padding(16)
        .background(Color(white: 0.95))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func transactionRow(_ expense: ReportDummyExpense) -> some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 34, height: 34)
                .background(Color.white.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                Text(ReportFormat.day(expense.date))
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            Text(ReportFormat.rupiahFull(expense.amount))
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(white: 0.38))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    let expenses = ReportDummyData.expenses(for: ReportDummyData.defaultDate, period: .weekly)
    let categories = ReportDummyData.categories(from: expenses)
    return ReportCategoryDetailSheet(
        category: categories[0],
        expenses: expenses.filter { $0.category == categories[0].name }
    )
}
