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

struct ReportDummyExpense: Identifiable {
    let id: UUID
    let date: Date
    let category: String
    let amount: Double
    let title: String

    init(id: UUID = UUID(), date: Date, category: String, amount: Double, title: String) {
        self.id = id
        self.date = date
        self.category = category
        self.amount = amount
        self.title = title
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
        calendar.timeZone = TimeZone(secondsFromGMT: 7 * 3600) ?? .current
        calendar.firstWeekday = 2
        return calendar
    }()

    private static let timeZone = TimeZone(secondsFromGMT: 7 * 3600)

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
        switch raw.lowercased() {
        case "food", "food & beverage", "food and beverage":
            return "Food & Beverage"
        case "transport", "transportation":
            return "Transportation"
        case "shopping":
            return "Shopping"
        default:
            return raw
        }
    }

    static func icon(for name: String) -> String {
        switch name.lowercased() {
        case "food & beverage", "food":
            return "fork.knife"
        case "transportation", "transport":
            return "car.fill"
        case "shopping":
            return "cart.fill"
        case "entertainment":
            return "film.fill"
        case "utilities":
            return "bolt.fill"
        default:
            return "tag.fill"
        }
    }

    static func color(for name: String) -> Color {
        switch name.lowercased() {
        case "food & beverage", "food":
            return Color(red: 0.29, green: 0.45, blue: 1.0)
        case "transportation", "transport":
            return Color(red: 0.18, green: 0.82, blue: 0.72)
        case "shopping":
            return Color(red: 1.0, green: 0.51, blue: 0.45)
        case "entertainment":
            return Color(red: 0.62, green: 0.45, blue: 0.98)
        case "utilities":
            return Color(red: 1.0, green: 0.72, blue: 0.28)
        default:
            return Color(white: 0.55)
        }
    }
}

enum ReportDummyData {
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 7 * 3600) ?? .current
        calendar.firstWeekday = 2
        return calendar
    }()

    static let expenses: [ReportDummyExpense] = [
        // July 2026 — Shopping dominant
        ReportDummyExpense(date: date(2026, 7, 5), category: "Shopping", amount: 400_000, title: "Uniqlo"),
        ReportDummyExpense(date: date(2026, 7, 12), category: "Food & Beverage", amount: 150_000, title: "Nasi Padang Sederhana"),
        ReportDummyExpense(date: date(2026, 7, 20), category: "Transportation", amount: 100_000, title: "Grab"),
        ReportDummyExpense(date: date(2026, 7, 28), category: "Shopping", amount: 250_000, title: "Shopee"),

        // August 2026 — Food & Entertainment
        ReportDummyExpense(date: date(2026, 8, 3), category: "Food & Beverage", amount: 300_000, title: "Joyi Coffee"),
        ReportDummyExpense(date: date(2026, 8, 10), category: "Entertainment", amount: 200_000, title: "Cinema XXI"),
        ReportDummyExpense(date: date(2026, 8, 18), category: "Food & Beverage", amount: 250_000, title: "Bakso Pak Kumis"),
        ReportDummyExpense(date: date(2026, 8, 22), category: "Transportation", amount: 180_000, title: "Shell"),
        ReportDummyExpense(date: date(2026, 8, 28), category: "Utilities", amount: 120_000, title: "PLN"),

        // September 2026 — 31 Aug-6 Sep
        ReportDummyExpense(date: date(2026, 9, 2), category: "Food & Beverage", amount: 90_000, title: "Kopi Kenangan"),
        ReportDummyExpense(date: date(2026, 9, 4), category: "Transportation", amount: 45_000, title: "Gojek"),

        // September 2026 — 7-13 Sep
        ReportDummyExpense(date: date(2026, 9, 8), category: "Food & Beverage", amount: 80_000, title: "Starbucks"),
        ReportDummyExpense(date: date(2026, 9, 8), category: "Transportation", amount: 40_000, title: "Parking"),
        ReportDummyExpense(date: date(2026, 9, 9), category: "Shopping", amount: 150_000, title: "Miniso"),
        ReportDummyExpense(date: date(2026, 9, 9), category: "Food & Beverage", amount: 50_000, title: "Chatime"),
        ReportDummyExpense(date: date(2026, 9, 10), category: "Transportation", amount: 200_000, title: "Grab"),
        ReportDummyExpense(date: date(2026, 9, 10), category: "Food & Beverage", amount: 70_000, title: "McDonald's"),
        ReportDummyExpense(date: date(2026, 9, 11), category: "Food & Beverage", amount: 400_000, title: "Joyi Coffee"),
        ReportDummyExpense(date: date(2026, 9, 11), category: "Transportation", amount: 300_000, title: "Grab"),
        ReportDummyExpense(date: date(2026, 9, 11), category: "Shopping", amount: 200_000, title: "Uniqlo"),
        ReportDummyExpense(date: date(2026, 9, 12), category: "Shopping", amount: 180_000, title: "H&M"),
        ReportDummyExpense(date: date(2026, 9, 12), category: "Entertainment", amount: 90_000, title: "Netflix"),

        // September 2026 — 14-20 Sep
        ReportDummyExpense(date: date(2026, 9, 15), category: "Food & Beverage", amount: 100_000, title: "Warung Tegal"),
        ReportDummyExpense(date: date(2026, 9, 15), category: "Utilities", amount: 80_000, title: "WiFi"),
        ReportDummyExpense(date: date(2026, 9, 20), category: "Transportation", amount: 250_000, title: "Bensin Shell"),
        ReportDummyExpense(date: date(2026, 9, 20), category: "Shopping", amount: 70_000, title: "Alfamart"),

        // September 2026 — 21-27 Sep
        ReportDummyExpense(date: date(2026, 9, 23), category: "Shopping", amount: 220_000, title: "Shopee"),
        ReportDummyExpense(date: date(2026, 9, 24), category: "Entertainment", amount: 80_000, title: "Spotify"),

        // September 2026 — 28 Sep-4 Oct
        ReportDummyExpense(date: date(2026, 9, 29), category: "Food & Beverage", amount: 110_000, title: "Pizza Hut"),
        ReportDummyExpense(date: date(2026, 9, 30), category: "Utilities", amount: 60_000, title: "PLN")
    ]

    static let defaultDate = date(2026, 9, 11)

    static var availableMonths: [Date] {
        let months = Set(expenses.compactMap { expense in
            calendar.date(from: calendar.dateComponents([.year, .month], from: expense.date))
        })
        return months.sorted()
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

    static func expenses(for date: Date, period: ReportPeriod) -> [ReportDummyExpense] {
        switch period {
        case .weekly:
            let selectedWeek = week(containing: date)
            return expenses.filter { isDate($0.date, in: selectedWeek) }
        case .monthly:
            return expenses.filter { calendar.isDate($0.date, equalTo: date, toGranularity: .month) }
        }
    }

    static func categories(from expenses: [ReportDummyExpense]) -> [ReportCategoryItem] {
        let grouped = Dictionary(grouping: expenses, by: \.category)
        let total = expenses.reduce(0) { $0 + $1.amount }

        return grouped
            .map { name, items in
                let amount = items.reduce(0) { $0 + $1.amount }
                return ReportCategoryItem(
                    id: name,
                    name: name,
                    amount: amount,
                    sliceWeight: total > 0 ? (amount / total) * 100 : 0,
                    color: CategoryStyle.color(for: name),
                    icon: CategoryStyle.icon(for: name)
                )
            }
            .sorted { $0.amount > $1.amount }
    }

    static func stepDate(_ date: Date, by offset: Int, period: ReportPeriod) -> Date? {
        switch period {
        case .weekly:
            let options = weeks(inMonthOf: date)
            guard let index = options.firstIndex(where: { isDate(date, in: $0) }) else { return nil }
            let nextIndex = index + offset
            guard options.indices.contains(nextIndex) else { return nil }
            return options[nextIndex].start
        case .monthly:
            guard let index = availableMonths.firstIndex(where: {
                calendar.isDate($0, equalTo: date, toGranularity: .month)
            }) else {
                return nil
            }
            let nextIndex = index + offset
            guard availableMonths.indices.contains(nextIndex) else { return nil }
            return availableMonths[nextIndex]
        }
    }

    static func canStep(_ date: Date, by offset: Int, period: ReportPeriod) -> Bool {
        stepDate(date, by: offset, period: period) != nil
    }

    static func nearestAvailableDate(to date: Date, period: ReportPeriod) -> Date {
        switch period {
        case .weekly:
            if let match = weeks(inMonthOf: date).first(where: { isDate(date, in: $0) }) {
                return match.start
            }
            return weeks(inMonthOf: date).first?.start ?? defaultDate
        case .monthly:
            if availableMonths.contains(where: {
                calendar.isDate($0, equalTo: date, toGranularity: .month)
            }) {
                return date
            }
            return availableMonths.last ?? defaultDate
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

    private static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12)) ?? .now
    }
}
