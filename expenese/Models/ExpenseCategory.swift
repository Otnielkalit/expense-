//
//  ExpenseCategory.swift
//  expenese
//
//  Created by otnielkalit on 12/09/26.
//

import Foundation
import SwiftData

@Model
final class ExpenseCategory {
    var name: String = ""
    var icon: String = ""
    var colorHex: String = ""
    
    init(name: String = "", icon: String = "", colorHex: String = "") {
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
    }
}
