//
//  HomeView.swift
//  expenese
//
//  Created by otnielkalit on 02/09/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \Expense.date, order: .reverse)
    private var expenses: [Expense]
    
    var body : some View {
        NavigationStack{
            List{
                Section("Summary"){
                    Text("Total: Rp\(total)")
                    Text("Jumlah transaksi: \(expenses.count)")
                }
                
                Section("New Transaction"){
                    ForEach(expenses) { expense in
                        ExpenseRow(expense: expense)
                        
                    }
                }
            }
            .navigationTitle("Home")
        }
    }
    
    private var total: String{
        expenses.reduce(0) { $0 + $1.amount }.formatted()
    }
}
