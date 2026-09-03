//
//  PaymentType.swift
//  expenese
//
//  Created by otnielkalit on 02/09/26.
//

import Foundation


enum PaymentType: String, Codable, CaseIterable {
    case bankTransfer = "Bank Transfer"
    case eWallet = "E-Wallet"
    case cash = "Cash"
    case qris = "QRIS"
    case creditCard = "Credit Card"
    
    
}
