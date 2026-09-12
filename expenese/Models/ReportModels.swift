//
//  ReportModels.swift
//  expenese
//
//  Created by Marzandi Zahran Affandi Leta on 11/09/26.
//

import SwiftUI

enum ReportPeriod: String, CaseIterable, Identifiable {
    case weekly = "Weekly"
    case monthly = "Monthly"

    var id: String { rawValue }
}

struct ReportCategoryItem: Identifiable, Equatable {
    let id: String
    let name: String
    let amount: Double
    let sliceWeight: Double
    let color: Color
    let icon: String

    var percent: Int {
        Int(sliceWeight.rounded())
    }

    var formattedAmount: String {
        ReportFormat.rupiah(amount)
    }
}

struct ReportWeek: Identifiable, Hashable {
    let start: Date
    let end: Date

    var id: Date { start }

    var label: String {
        ReportFormat.weekRange(from: start, to: end)
    }
}

enum ReportFormat {
    static func rupiah(_ amount: Double) -> String {
        if amount >= 1_000 {
            let thousands = amount / 1_000
            if thousands.rounded() == thousands {
                return "Rp \(Int(thousands)) K"
            }
            return "Rp \(Int(thousands.rounded())) K"
        }
        return "Rp \(Int(amount))"
    }

    static func compactRupiah(_ amount: Double) -> String {
        if amount >= 1_000_000 {
            let millions = amount / 1_000_000
            if millions.rounded() == millions {
                return "Rp \(Int(millions)) M"
            }
            let text = String(format: "%.1f", millions)
            return "Rp \(text) M"
        }
        return rupiah(amount)
    }

    static func month(_ date: Date) -> String {
        monthFormatter.string(from: date)
    }

    static func day(_ date: Date) -> String {
        dayFormatter.string(from: date)
    }

    static func rupiahFull(_ amount: Double) -> String {
        let number = NumberFormatter()
        number.numberStyle = .decimal
        number.groupingSeparator = "."
        number.maximumFractionDigits = 0
        let value = number.string(from: NSNumber(value: amount)) ?? "\(Int(amount))"
        return "Rp \(value)"
    }

    static func weekRange(from start: Date, to end: Date) -> String {
        if calendar.isDate(start, equalTo: end, toGranularity: .month) {
            return "\(dayNumber.string(from: start)) - \(dayNumber.string(from: end)) \(shortMonth.string(from: start))"
        }
        return "\(dayNumber.string(from: start)) \(shortMonth.string(from: start)) - \(dayNumber.string(from: end)) \(shortMonth.string(from: end))"
    }

    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.current
        calendar.firstWeekday = 2
        return calendar
    }()

    private static let timeZone = TimeZone.current

    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()

    private static let dayNumber: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        formatter.dateFormat = "d"
        return formatter
    }()

    private static let shortMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        formatter.dateFormat = "MMM"
        return formatter
    }()
}

enum CategoryStyle {
    static func displayName(for raw: String) -> String {
        CategoryCatalog.displayName(for: raw)
    }

    static func icon(for name: String, customCategories: [Category] = []) -> String {
        if let custom = customCategories.first(where: { $0.name == name }) { return custom.icon }
        return CategoryCatalog.icon(for: name)
    }

    static func color(for name: String, customCategories: [Category] = []) -> Color {
        if let custom = customCategories.first(where: { $0.name == name }) { return Color(hex: custom.colorHex) }
        return CategoryCatalog.color(for: name)
    }
}

enum ReportHelper {
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.current
        calendar.firstWeekday = 2
        return calendar
    }()
    
    static var defaultDate: Date {
        Date()
    }

    static func availableMonths(from expenses: [Expense]) -> [Date] {
        let months = Set(expenses.compactMap { expense in
            calendar.date(from: calendar.dateComponents([.year, .month], from: expense.date))
        })
        let sorted = months.sorted()
        return sorted.isEmpty ? [calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!] : sorted
    }

    static func week(containing date: Date) -> ReportWeek {
        let start = startOfWeek(for: date)
        let end = calendar.date(byAdding: .day, value: 6, to: start) ?? date
        return ReportWeek(start: start, end: end)
    }

    static func weeks(inMonthOf date: Date) -> [ReportWeek] {
        guard
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date)),
            let nextMonth = calendar.date(byAdding: .month, value: 1, to: monthStart),
            let monthEnd = calendar.date(byAdding: .day, value: -1, to: nextMonth)
        else {
            return []
        }

        var weekStart = startOfWeek(for: monthStart)
        var result: [ReportWeek] = []

        while weekStart <= monthEnd, result.count < 6 {
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart.addingTimeInterval(6 * 24 * 3600)
            result.append(ReportWeek(start: weekStart, end: weekEnd))
            weekStart = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart.addingTimeInterval(7 * 24 * 3600)
        }

        return result
    }

    static func filteredExpenses(from expenses: [Expense], for date: Date, period: ReportPeriod) -> [Expense] {
        let expensesOnly = expenses.filter { $0.isExpense }
        switch period {
        case .weekly:
            let selectedWeek = week(containing: date)
            return expensesOnly.filter { isDate($0.date, in: selectedWeek) }
        case .monthly:
            return expensesOnly.filter { calendar.isDate($0.date, equalTo: date, toGranularity: .month) }
        }
    }

    static func categories(from expenses: [Expense], customCategories: [Category] = []) -> [ReportCategoryItem] {
        let grouped = Dictionary(grouping: expenses, by: { CategoryStyle.displayName(for: $0.category) })
        let total = expenses.reduce(0) { $0 + $1.amount }

        return grouped
            .map { name, items in
                let amount = items.reduce(0) { $0 + $1.amount }
                return ReportCategoryItem(
                    id: name,
                    name: name,
                    amount: amount,
                    sliceWeight: total > 0 ? (amount / total) * 100 : 0,
                    color: CategoryStyle.color(for: name, customCategories: customCategories),
                    icon: CategoryStyle.icon(for: name, customCategories: customCategories)
                )
            }
            .sorted { $0.amount > $1.amount }
    }

    static func stepDate(_ date: Date, by offset: Int, period: ReportPeriod, allExpenses: [Expense]) -> Date? {
        switch period {
        case .weekly:
            let options = weeks(inMonthOf: date)
            guard let index = options.firstIndex(where: { isDate(date, in: $0) }) else { return nil }
            let nextIndex = index + offset
            guard options.indices.contains(nextIndex) else { return nil }
            return options[nextIndex].start
        case .monthly:
            let months = availableMonths(from: allExpenses)
            guard let index = months.firstIndex(where: {
                calendar.isDate($0, equalTo: date, toGranularity: .month)
            }) else {
                return nil
            }
            let nextIndex = index + offset
            guard months.indices.contains(nextIndex) else { return nil }
            return months[nextIndex]
        }
    }

    static func canStep(_ date: Date, by offset: Int, period: ReportPeriod, allExpenses: [Expense]) -> Bool {
        stepDate(date, by: offset, period: period, allExpenses: allExpenses) != nil
    }

    static func nearestAvailableDate(to date: Date, period: ReportPeriod, allExpenses: [Expense]) -> Date {
        switch period {
        case .weekly:
            if let match = weeks(inMonthOf: date).first(where: { isDate(date, in: $0) }) {
                return match.start
            }
            return weeks(inMonthOf: date).first?.start ?? defaultDate
        case .monthly:
            let months = availableMonths(from: allExpenses)
            if months.contains(where: {
                calendar.isDate($0, equalTo: date, toGranularity: .month)
            }) {
                return date
            }
            return months.last ?? defaultDate
        }
    }

    static func isDate(_ date: Date, in week: ReportWeek) -> Bool {
        let day = calendar.startOfDay(for: date)
        let start = calendar.startOfDay(for: week.start)
        let end = calendar.startOfDay(for: week.end)
        return day >= start && day <= end
    }

    private static func startOfWeek(for date: Date) -> Date {
        let startOfDay = calendar.startOfDay(for: date)
        let weekday = calendar.component(.weekday, from: startOfDay)
        let daysFromMonday = (weekday + 5) % 7
        return calendar.date(byAdding: .day, value: -daysFromMonday, to: startOfDay) ?? startOfDay
    }
}
