//
//  ReportView.swift
//  expenese
//
//  Created by Marzandi Zahran Affandi Leta on 11/09/26.
//

import SwiftUI
import SwiftData

struct ReportView: View {
    @Query private var expenses: [Expense]
    @Query private var customCategories: [Category]
    
    @State private var period: ReportPeriod = .weekly
    @State private var selectedDate: Date = ReportHelper.defaultDate

    private var filteredExpenses: [Expense] {
        ReportHelper.filteredExpenses(from: expenses, for: selectedDate, period: period)
    }

    private var displayedCategories: [ReportCategoryItem] {
        ReportHelper.categories(from: filteredExpenses, customCategories: customCategories)
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    periodPicker

                    Text("Expenses Report")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)

                    ReportDateFilter(period: period, selectedDate: $selectedDate, allExpenses: expenses)

                    if displayedCategories.isEmpty {
                        emptyState
                    } else {
                        insightText
                        ReportPieChartView(
                            categories: displayedCategories,
                            expenses: filteredExpenses
                        )
                        ReportCategoryListView(categories: displayedCategories)
                            .id("\(period.rawValue)-\(selectedDate.timeIntervalSince1970)")
                    }

                    Spacer().frame(height: 24)
                }
                .padding(.horizontal, 22)
                .padding(.top, 8)
            }
            .background(Color.white)
            .toolbar(.hidden, for: .navigationBar)
            .onChange(of: period) { _, newPeriod in
                selectedDate = ReportHelper.nearestAvailableDate(to: selectedDate, period: newPeriod, allExpenses: expenses)
            }
        }
    }
}

private extension ReportView {
    var header: some View {
        HStack(spacing: 8) {
            Text("Report")
                .font(.system(size: 28, weight: .bold))
            Spacer()
        }
        .foregroundColor(.black)
        .padding(.top, 4)
    }

    var periodPicker: some View {
        HStack(spacing: 0) {
            ForEach(ReportPeriod.allCases) { item in
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        period = item
                    }
                } label: {
                    Text(item.rawValue)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(period == item ? .black : Color.gray.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background {
                            if period == item {
                                Capsule()
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.08), radius: 6, y: 1)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(5)
        .background(Color(white: 0.93))
        .clipShape(Capsule())
    }

    var insightText: some View {
        VStack(spacing: 2) {
            (Text("Your ")
                .fontWeight(.regular)
            + Text("\(topCategoryName) Expense")
                .fontWeight(.bold))
            .font(.system(size: 18))

            if let comparisonCategoryName {
                Text("More High from \(comparisonCategoryName)")
                    .font(.system(size: 18, weight: .regular))
            }
        }
        .foregroundColor(.black)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }

    var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "chart.pie")
                .font(.system(size: 36))
                .foregroundColor(.gray.opacity(0.5))
            Text("No expenses in this \(period == .weekly ? "week" : "month")")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }

    var topCategoryName: String {
        displayedCategories.max(by: { $0.amount < $1.amount })?.name ?? "Food & Beverage"
    }

    var comparisonCategoryName: String? {
        let sorted = displayedCategories.sorted { $0.amount > $1.amount }
        guard sorted.count > 1 else { return nil }
        return sorted[1].name
    }
}

private struct ReportDateFilter: View {
    let period: ReportPeriod
    @Binding var selectedDate: Date
    let allExpenses: [Expense]

    var body: some View {
        HStack(spacing: 8) {
            stepButton(offset: -1, icon: "chevron.left")

            Menu {
                switch period {
                case .weekly:
                    ForEach(ReportHelper.weeks(inMonthOf: selectedDate)) { week in
                        Button {
                            selectedDate = week.start
                        } label: {
                            dateMenuLabel(
                                week.label,
                                isSelected: ReportHelper.isDate(selectedDate, in: week)
                            )
                        }
                    }
                case .monthly:
                    ForEach(ReportHelper.availableMonths(from: allExpenses), id: \.self) { month in
                        Button {
                            selectedDate = month
                        } label: {
                            dateMenuLabel(ReportFormat.month(month), isSelected: isSameMonth(month))
                        }
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 14, weight: .semibold))
                    Text(filterLabel)
                        .font(.system(size: 15, weight: .medium))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }

            stepButton(offset: 1, icon: "chevron.right")
        }
        .padding(.horizontal, 8)
        .background(Color(white: 0.93))
        .clipShape(Capsule())
    }

    private var filterLabel: String {
        switch period {
        case .weekly:
            return ReportHelper.week(containing: selectedDate).label
        case .monthly:
            return ReportFormat.month(selectedDate)
        }
    }

    private func stepButton(offset: Int, icon: String) -> some View {
        let enabled = ReportHelper.canStep(selectedDate, by: offset, period: period, allExpenses: allExpenses)
        return Button {
            guard let next = ReportHelper.stepDate(selectedDate, by: offset, period: period, allExpenses: allExpenses) else { return }
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDate = next
            }
        } label: {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(enabled ? .black : .gray.opacity(0.35))
                .frame(width: 36, height: 36)
        }
        .disabled(!enabled)
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func dateMenuLabel(_ title: String, isSelected: Bool) -> some View {
        if isSelected {
            Label(title, systemImage: "checkmark")
        } else {
            Text(title)
        }
    }

    private func isSameMonth(_ date: Date) -> Bool {
        Calendar(identifier: .gregorian).isDate(date, equalTo: selectedDate, toGranularity: .month)
    }
}

#Preview {
    ReportView()
}
