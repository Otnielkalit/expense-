//
//  Category.swift
//  expenese
//
//  Created by Marzandi Zahran Affandi Leta on 12/09/26.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Category {
    var name: String = ""
    var icon: String = "tag.fill"
    var colorHex: String = "8E8E93"
    var sortOrder: Int = 0
    var isPreset: Bool = false

    init(
        name: String,
        icon: String,
        colorHex: String,
        sortOrder: Int,
        isPreset: Bool = false
    ) {
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.sortOrder = sortOrder
        self.isPreset = isPreset
    }

    var color: Color {
        Color(hex: colorHex)
    }
}

struct CategoryPreset: Identifiable {
    let name: String
    let icon: String
    let colorHex: String
    let aliases: [String]

    var id: String { name }

    var color: Color {
        Color(hex: colorHex)
    }
}

enum CategoryCatalog {
    static let presets: [CategoryPreset] = [
        CategoryPreset(name: "Food & Beverage", icon: "fork.knife", colorHex: "F5C63A", aliases: ["food", "food and beverage", "fnb"]),
        CategoryPreset(name: "Shopping", icon: "cart.fill", colorHex: "3DDCFF", aliases: ["shop"]),
        CategoryPreset(name: "Health", icon: "cross.case.fill", colorHex: "2DD4BF", aliases: ["medical", "healthcare"]),
        CategoryPreset(name: "Travelling", icon: "airplane", colorHex: "7C6FFF", aliases: ["travel", "traveling", "trip"]),
        CategoryPreset(name: "Entertainment", icon: "tv.fill", colorHex: "C44DFF", aliases: ["fun", "hobby"]),
        CategoryPreset(name: "Gym", icon: "figure.run", colorHex: "FF9F0A", aliases: ["fitness", "sport", "sports"]),
        CategoryPreset(name: "Rental", icon: "doc.fill", colorHex: "A2845E", aliases: ["rent", "housing", "kost"]),
        CategoryPreset(name: "Transportation", icon: "car.fill", colorHex: "FF5C8A", aliases: ["transport"]),
        CategoryPreset(name: "Utilities", icon: "bolt.fill", colorHex: "FFB340", aliases: ["bills", "utility"]),
        CategoryPreset(name: "Education", icon: "book.fill", colorHex: "0A84FF", aliases: ["school", "study"])
    ]

    static let icons: [String] = [
        "fork.knife", "cart.fill", "cross.case.fill", "airplane",
        "tv.fill", "figure.run", "doc.fill", "car.fill",
        "bolt.fill", "book.fill", "house.fill", "bag.fill",
        "cup.and.saucer.fill", "gamecontroller.fill", "gift.fill",
        "heart.fill", "film.fill", "tag.fill"
    ]

    static let colors: [(hex: String, color: Color)] = [
        ("007AFF", .blue),
        ("FF3B30", .red),
        ("34C759", .green),
        ("FF9F0A", .orange),
        ("AF52DE", .purple),
        ("FFD60A", .yellow),
        ("FF2D55", .pink),
        ("32ADE6", .cyan),
        ("A2845E", Color(hex: "A2845E")),
        ("2DD4BF", Color(hex: "2DD4BF"))
    ]

    static func preset(matching raw: String) -> CategoryPreset? {
        let key = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return presets.first { preset in
            preset.name.lowercased() == key || preset.aliases.contains(key)
        }
    }

    static func displayName(for raw: String) -> String {
        preset(matching: raw)?.name ?? raw
    }

    static func icon(for raw: String, in categories: [Category] = []) -> String {
        if let stored = find(raw, in: categories) {
            return stored.icon
        }
        return preset(matching: raw)?.icon ?? "tag.fill"
    }

    static func color(for raw: String, in categories: [Category] = []) -> Color {
        if let stored = find(raw, in: categories) {
            return stored.color
        }
        return preset(matching: raw)?.color ?? Color(white: 0.55)
    }

    static func colorHex(for raw: String, in categories: [Category] = []) -> String {
        if let stored = find(raw, in: categories) {
            return stored.colorHex
        }
        return preset(matching: raw)?.colorHex ?? "8E8E93"
    }

    static func find(_ raw: String, in categories: [Category]) -> Category? {
        let key = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let canonical = displayName(for: key)
        return categories.first {
            $0.name.localizedCaseInsensitiveCompare(key) == .orderedSame
                || $0.name.localizedCaseInsensitiveCompare(canonical) == .orderedSame
        }
    }
}

enum CategoryStore {
    static func seedDefaultsIfNeeded(context: ModelContext) {
        let existing = (try? context.fetch(FetchDescriptor<Category>())) ?? []
        let existingNames = Set(existing.map { $0.name.lowercased() })

        for (index, preset) in CategoryCatalog.presets.enumerated() {
            guard !existingNames.contains(preset.name.lowercased()) else { continue }
            context.insert(
                Category(
                    name: preset.name,
                    icon: preset.icon,
                    colorHex: preset.colorHex,
                    sortOrder: index,
                    isPreset: true
                )
            )
        }

        try? context.save()
    }

    static func nextSortOrder(in context: ModelContext) -> Int {
        var descriptor = FetchDescriptor<Category>(sortBy: [SortDescriptor(\.sortOrder, order: .reverse)])
        descriptor.fetchLimit = 1
        let last = try? context.fetch(descriptor).first
        return (last?.sortOrder ?? -1) + 1
    }

    static func categoryNamed(_ name: String, in context: ModelContext) -> Category? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let existing = (try? context.fetch(FetchDescriptor<Category>())) ?? []
        return CategoryCatalog.find(trimmed, in: existing)
    }

    static func update(
        _ category: Category,
        name: String,
        icon: String,
        colorHex: String,
        in context: ModelContext
    ) {
        let oldName = category.name
        category.name = name
        category.icon = icon
        category.colorHex = colorHex

        guard oldName.localizedCaseInsensitiveCompare(name) != .orderedSame else { return }

        let expenses = (try? context.fetch(FetchDescriptor<Expense>())) ?? []
        for expense in expenses {
            let matchesStoredName = expense.category.localizedCaseInsensitiveCompare(oldName) == .orderedSame
            let matchesDisplayName = CategoryCatalog.displayName(for: expense.category)
                .localizedCaseInsensitiveCompare(oldName) == .orderedSame
            if matchesStoredName || matchesDisplayName {
                expense.category = name
            }
        }
    }
}
