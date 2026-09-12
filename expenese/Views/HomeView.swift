//
//  HomeView.swift
//  expenese
//
//  Created by otnielkalit on 02/09/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    
    var body: some View {
        ZStack(alignment: .top) {
            Theme.bgApp.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 30) {
                    topHeaderSection
                    
                    bottomContentSection
                    
                    // Kalender UI
                    calendarView
                    
                    Spacer().frame(height: 100)
                }
                .padding(.top, 20)
            }
        }
    }
}

// MARK: - Komponen UI
extension HomeView {
    
    // --- TOP HEADER ---
    private var topHeaderSection: some View {
        VStack(spacing: 30) {
            // Baris Atas: Bulan dan Settings
            HStack {
                Spacer()
                
                HStack {
                    Text("April")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(Theme.cardWhite)
                .clipShape(Capsule())
                .shadow(color: .gray.opacity(0.1), radius: 5, y: 2)
                
                Spacer()
                
                Image(systemName: "gearshape.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Theme.textDark)
                    .padding(.trailing, 24)
            }
            // Posisikan picker sedikit ke kiri karena ada tombol setting di kanan
            .padding(.leading, 54)
            
            // Angka Total
            VStack(spacing: 8) {
                Text("Total **Expense**")
                    .font(.system(size: 20, design: .rounded))
                    .foregroundColor(Theme.textDark)
                
                Text("Rp 500.000") // Sementara hardcode
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.expenseRed)
                    .shadow(color: Theme.expenseRed.opacity(0.3), radius: 10, y: 5)
                
                Text("Your **Balance** Rp 100.000")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(Theme.incomePurple)
            }
        }
    }
    
    // --- BOTTOM CONTENT ---
    private var bottomContentSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            // Your Money (Income & Expense Cards)
            VStack(alignment: .leading, spacing: 12) {
                Text("Your Money")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textDark)
                
                HStack(spacing: 16) {
                    moneyCard(title: "Income", amount: "Rp 600.000", icon: "dollarsign", bg: Theme.bgIncomeCard, logoColor: Theme.incomePurple)
                    moneyCard(title: "Expenses", amount: "Rp 500.000", icon: "wallet.pass.fill", bg: Theme.bgExpenseCard, logoColor: Theme.expenseRed)
                }
            }
            .padding(.horizontal, 24)
            
            // Your Transaction
            VStack(alignment: .leading, spacing: 16) {
                Text("Your Transaction")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textDark)
                
                HStack {
                    Text("Tuesday, 01 April 2026")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("Total **Rp 500.000**")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(Theme.expenseRed)
                }
                
                Text("Last Record")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textDark)
                    .padding(.top, 8)
                
                // List Transaksi bergaya Card Putih bersatu
                VStack(spacing: 0) {
                    transactionRow(icon: "fork.knife", color: .yellow, name: "Makan Sate Padang", amount: "-Rp 200 K", date: "1 Apr")
                    Divider().padding(.leading, 50)
                    transactionRow(icon: "car.fill", color: Theme.expenseRed, name: "Grab Car Pollux Habibi", amount: "-Rp 100 K", date: "1 Apr")
                    Divider().padding(.leading, 50)
                    transactionRow(icon: "house.fill", color: Theme.incomePurple, name: "Bayar Listrik Rusun", amount: "-Rp 200 K", date: "1 Apr")
                    Divider()
                    
                    Button("Show more") {
                        // Action
                    }
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.blue)
                    .padding(.vertical, 12)
                }
                .background(Theme.cardWhite)
                .cornerRadius(20)
                .shadow(color: .gray.opacity(0.1), radius: 10, y: 5)
            }
            .padding(.horizontal, 24)
        }
    }
    
    // --- CALENDAR UI ---
    private var calendarView: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Header Kalender (Bulan & Tombol Panah)
            HStack {
                Text("April 2026")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textDark)
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.blue)
                
                Spacer()
                
                HStack(spacing: 24) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                        .font(.system(size: 18, weight: .medium))
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                        .font(.system(size: 18, weight: .medium))
                }
            }
            
            // Grid Hari dan Tanggal
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            let days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
            
            LazyVGrid(columns: columns, spacing: 16) {
                // Baris Nama Hari
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray.opacity(0.8))
                }
                
                // Dua kotak kosong untuk hari Minggu & Senin (Karena tgl 1 jatuh di hari Selasa)
                Text("")
                Text("")
                
                // Cetak Tanggal 1 s/d 30
                ForEach(1...30, id: \.self) { date in
                    VStack(spacing: 4) {
                        if date == 1 {
                            // Tanggal 1: Lingkaran Biru Muda
                            Text("\(date)")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.blue)
                                .frame(width: 34, height: 34)
                                .background(Color.blue.opacity(0.15))
                                .clipShape(Circle())
                            
                            // Tulisan merah "500K"
                            Text("500K")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.expenseRed)
                        } else if date == 21 {
                            // Tanggal 21: Warna Biru
                            Text("\(date)")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.blue)
                                .frame(width: 34, height: 34)
                            
                            Text("").font(.system(size: 10)) // Ruang kosong agar sejajar
                        } else {
                            // Tanggal Biasa
                            Text("\(date)")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Theme.textDark)
                                .frame(width: 34, height: 34)
                            
                            Text("").font(.system(size: 10)) // Ruang kosong agar sejajar
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
    }
    
    // --- KOMPONEN KECIL ---
    private func moneyCard(title: String, amount: String, icon: String, bg: Color, logoColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(logoColor)
                .clipShape(Circle())
                .shadow(color: logoColor.opacity(0.4), radius: 5, y: 3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(Theme.textDark.opacity(0.8))
                Text(amount)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textDark)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(bg)
        .cornerRadius(24)
    }
    
    private func transactionRow(icon: String, color: Color, name: String, amount: String, date: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(color)
                .clipShape(Circle())
            
            Text(name)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Theme.textDark)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(amount)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.expenseRed)
                Text(date)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}


