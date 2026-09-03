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

    static func match(in text: String) -> String {
        let lower = text.lowercased()
        for item in keyword {
            if lower.contains(item.keyword) {
                return item.category
            }
        }

        return "Other"
    }
}
