//
//  Theme.swift
//  expenese
//
//  Created by otnielkalit on 10/09/26.
//



import SwiftUI

// Extension agar SwiftUI bisa membaca warna Hex (misal: "DC565A")
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue:  Double(b) / 255, opacity: Double(a) / 255)
    }
}

struct Theme {
    // Warna sesuai permintaan desainer
    static let expenseRed = Color(hex: "DC565A")
    static let incomePurple = Color(hex: "8B52FC")
    static let bgExpenseCard = Color(hex: "FEECEE")
    static let bgIncomeCard = Color(hex: "F0EBFE")
    
    // Warna tambahan untuk Layout Baru
    static let bgApp = Color(hex: "F7F7FA") // Background utama (Abu-abu sangat muda)
    static let textDark = Color(hex: "2D2F3A") // Teks judul utama
    static let cardWhite = Color.white // Background untuk card Last Record
}

