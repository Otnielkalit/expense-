//
//  CategoryMapper.swift
//  expenese
//
//  Created by otnielkalit on 02/09/26.
//

import Foundation

enum CategoryMapper {
    static let keyword: [(keyword: String, category: String)] = [
        // Makanan
        ("meatball", "Food"),
        ("bakso", "Food"),
        ("rice", "Food"),
        ("nasi", "Food"),
        ("coffee", "Food"),
        ("breakfast", "Food"),
        ("lunch", "Food"),
        ("dinner", "Food"),
        ("snack", "Food"),
        ("food", "Food"),
        // Transport
        ("taxi", "Transport"),
        ("uber", "Transport"),
        ("fuel", "Transport"),
        ("bensin", "Transport"),
        ("parking", "Transport"),
        ("transport", "Transport"),
        // Belanja
        ("clothes", "Shopping"),
        ("shoes", "Shopping"),
        ("shopping", "Shopping"),
        // Hiburan
        ("movie", "Entertainment"),
        ("game", "Entertainment"),
        ("spotify", "Entertainment"),
        ("netflix", "Entertainment"),
        // Utilitas
        ("electricity", "Utilities"),
        ("water", "Utilities"),
        ("internet", "Utilities"),
        ("phone", "Utilities")
    ]

    static func match(in text: String, customCategories: [String] = []) -> String {
        let lower = text.lowercased()
        
        // 1. Check custom categories first
        for cat in customCategories {
            if lower.contains(cat.lowercased()) {
                return cat
            }
        }
        
        // 2. Fallback to hardcoded keyword map
        for item in keyword {
            if lower.contains(item.keyword) {
                return item.category
            }
        }

        return "Other"
    }
}
