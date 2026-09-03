//
//  PaymentMapper.swift
//  expenese
//
//  Created by otnielkalit on 02/09/26.
//

import Foundation

enum PaymentMapper {
    static let keywords: [(keyword: String, method: String, type: PaymentType)] = [
        ("mandiri", "Bank Mandiri", .bankTransfer),
        ("bca", "BCA", .bankTransfer),
        ("bri", "BRI", .bankTransfer),
        ("bni", "BNI", .bankTransfer),
        ("qris", "QRIS", .qris),
        ("gopay", "GoPay", .eWallet),
        ("ovo", "OVO", .eWallet),
        ("dana", "Dana", .eWallet),
        ("shopeepay", "ShopeePay", .eWallet),
        ("cash", "Cash", .cash)
    ]
    
    static func match(in text: String) -> (method: String, type: PaymentType)? {
        let lower = text.lowercased()
        for item in keywords {
            if lower.contains(item.keyword) {
                return (item.method, item.type)
            }
        }
        return nil
    }
}
