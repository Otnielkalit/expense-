//
//  CategoryMapper.swift
//  expenese
//
//  Created by otnielkalit on 02/09/26.
//

import Foundation

enum CategoryMapper {
    static let keyword: [(keyword: String, category: String)] = [
        ("meatball", "Food & Beverage"),
        ("bakso", "Food & Beverage"),
        ("rice", "Food & Beverage"),
        ("nasi", "Food & Beverage"),
        ("coffee", "Food & Beverage"),
        ("kopi", "Food & Beverage"),
        ("breakfast", "Food & Beverage"),
        ("lunch", "Food & Beverage"),
        ("dinner", "Food & Beverage"),
        ("snack", "Food & Beverage"),
        ("food", "Food & Beverage"),
        ("makan", "Food & Beverage"),
        ("restaurant", "Food & Beverage"),
        ("taxi", "Transportation"),
        ("uber", "Transportation"),
        ("grab", "Transportation"),
        ("gojek", "Transportation"),
        ("fuel", "Transportation"),
        ("bensin", "Transportation"),
        ("parking", "Transportation"),
        ("parkir", "Transportation"),
        ("transport", "Transportation"),
        ("clothes", "Shopping"),
        ("shoes", "Shopping"),
        ("shopping", "Shopping"),
        ("belanja", "Shopping"),
        ("shopee", "Shopping"),
        ("movie", "Entertainment"),
        ("bioskop", "Entertainment"),
        ("game", "Entertainment"),
        ("spotify", "Entertainment"),
        ("netflix", "Entertainment"),
        ("karaoke", "Entertainment"),
        ("electricity", "Utilities"),
        ("listrik", "Utilities"),
        ("water", "Utilities"),
        ("internet", "Utilities"),
        ("wifi", "Utilities"),
        ("phone", "Utilities"),
        ("hospital", "Health"),
        ("doctor", "Health"),
        ("obat", "Health"),
        ("apotek", "Health"),
        ("pharmacy", "Health"),
        ("medicine", "Health"),
        ("gym", "Gym"),
        ("fitness", "Gym"),
        ("sport", "Gym"),
        ("hotel", "Travelling"),
        ("flight", "Travelling"),
        ("airplane", "Travelling"),
        ("ticket", "Travelling"),
        ("travel", "Travelling"),
        ("vacation", "Travelling"),
        ("liburan", "Travelling"),
        ("rent", "Rental"),
        ("sewa", "Rental"),
        ("kost", "Rental"),
        ("kos", "Rental"),
        ("school", "Education"),
        ("course", "Education"),
        ("buku", "Education"),
        ("education", "Education")
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
