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
    @Query private var customCategories: [Category]
    @State private var showSettings = false
    @State private var selectedMonth = Date()
    @State private var selectedDayDate: Date? = nil
    
    // Computed properties for real data
    private var currentMonthExpenses: [Expense] {
        let calendar = Calendar.current
        return expenses.filter { calendar.isDate($0.date, equalTo: selectedMonth, toGranularity: .month) }
    }
    
    private var totalExpense: Double {
        currentMonthExpenses.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
    }
    private var totalIncome: Double {
        currentMonthExpenses.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount }
    }
    private var balance: Double {
        totalIncome - totalExpense
    }
    
    private func expensesForDay(_ day: Int) -> Double {
        let calendar = Calendar.current
        return currentMonthExpenses.filter { 
            $0.isExpense && 
            calendar.component(.day, from: $0.date) == day
        }.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationStack {
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
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(item: Binding<Date?>(
            get: { selectedDayDate },
            set: { selectedDayDate = $0 }
        )) { date in
            DailyExpenseSheet(
                date: date,
                expenses: currentMonthExpenses.filter { Calendar.current.isDate($0.date, inSameDayAs: date) },
                customCategories: customCategories
            )
        }
        }
    }
}

extension Date: Identifiable {
    public var id: TimeInterval {
        self.timeIntervalSince1970
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
                
                Menu {
                    ForEach(-5...0, id: \.self) { offset in
                        if let monthDate = Calendar.current.date(byAdding: .month, value: offset, to: Date()) {
                            Button(ReportFormat.month(monthDate)) {
                                selectedMonth = monthDate
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(ReportFormat.month(selectedMonth))
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Theme.textDark)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.textDark)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Theme.cardWhite)
                    .clipShape(Capsule())
                    .shadow(color: .gray.opacity(0.1), radius: 5, y: 2)
                }
                
                Spacer()
                
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Theme.textDark)
                }
                .padding(.trailing, 24)
            }
            // Posisikan picker sedikit ke kiri karena ada tombol setting di kanan
            .padding(.leading, 54)
            
            // Angka Total
            VStack(spacing: 8) {
                Text("Total **Expense**")
                    .font(.system(size: 20, design: .rounded))
                    .foregroundColor(Theme.textDark)
                
                Text(ReportFormat.rupiahFull(totalExpense))
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.expenseRed)
                    .shadow(color: Theme.expenseRed.opacity(0.3), radius: 10, y: 5)
                
                Text("Your **Balance** \(ReportFormat.rupiahFull(balance))")
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
                    moneyCard(title: "Income", amount: ReportFormat.rupiahFull(totalIncome), icon: "dollarsign", bg: Theme.bgIncomeCard, logoColor: Theme.incomePurple)
                    moneyCard(title: "Expenses", amount: ReportFormat.rupiahFull(totalExpense), icon: "wallet.pass.fill", bg: Theme.bgExpenseCard, logoColor: Theme.expenseRed)
                }
            }
            .padding(.horizontal, 24)
            
            // Your Transaction
            VStack(alignment: .leading, spacing: 16) {
                Text("Your Transaction")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textDark)
                
                HStack {
                    Text("Today, \(ReportFormat.day(Date()))")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("Total **\(ReportFormat.rupiahFull(totalExpense))**")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(Theme.expenseRed)
                }
                
                Text("Last Record")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textDark)
                    .padding(.top, 8)
                
                // List Transaksi bergaya Card Putih bersatu
                VStack(spacing: 0) {
                    if currentMonthExpenses.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "tray")
                                .font(.system(size: 30))
                                .foregroundColor(.gray.opacity(0.5))
                            Text("No records found.")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 32)
                        .frame(maxWidth: .infinity)
                    } else {
                        ForEach(Array(currentMonthExpenses.prefix(3).enumerated()), id: \.element.id) { index, expense in
                            transactionRow(
                                icon: getCategoryIcon(expense.category),
                                color: getCategoryColor(expense.category),
                                name: expense.desc.isEmpty ? expense.category : expense.desc,
                                amount: (expense.isExpense ? "-" : "+") + ReportFormat.rupiahFull(expense.amount),
                                date: ReportFormat.day(expense.date),
                                isExpense: expense.isExpense
                            )
                            if index < min(currentMonthExpenses.count, 3) - 1 {
                                Divider().padding(.leading, 50)
                            }
                        }
                        
                        Divider().padding(.leading, 50)
                        
                        NavigationLink(destination: HistoryView()) {
                            Text("Show more")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.blue)
                                .padding(.vertical, 12)
                        }
                    }
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
                Text(ReportFormat.month(selectedMonth))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textDark)
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.blue)
                
                Spacer()
                
                HStack(spacing: 24) {
                    Button(action: {
                        if let prev = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) {
                            selectedMonth = prev
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                            .font(.system(size: 18, weight: .medium))
                    }
                    
                    Button(action: {
                        if let next = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) {
                            selectedMonth = next
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.blue)
                            .font(.system(size: 18, weight: .medium))
                    }
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
                    let dayTotal = expensesForDay(date)
                    Button(action: {
                        if let clickedDate = Calendar.current.date(bySetting: .day, value: date, of: selectedMonth) {
                            selectedDayDate = clickedDate
                        }
                    }) {
                        VStack(spacing: 4) {
                            if dayTotal > 0 {
                                // Ada Pengeluaran di Hari Ini
                                Text("\(date)")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.blue)
                                    .frame(width: 34, height: 34)
                                    .background(Color.blue.opacity(0.15))
                                    .clipShape(Circle())
                                
                                Text(ReportFormat.rupiah(dayTotal))
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundColor(Theme.expenseRed)
                            } else if date == Calendar.current.component(.day, from: Date()) && Calendar.current.isDate(selectedMonth, equalTo: Date(), toGranularity: .month) {
                                // Hari Ini (Today) tapi tidak ada pengeluaran, HANYA ditandai jika bulannya adalah bulan ini
                                Text("\(date)")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(width: 34, height: 34)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                
                                Text("").font(.system(size: 10))
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
    
    private func transactionRow(icon: String, color: Color, name: String, amount: String, date: String, isExpense: Bool = true) -> some View {
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
                    .foregroundColor(isExpense ? Theme.expenseRed : Theme.incomePurple)
                Text(date)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private func getCategoryIcon(_ name: String) -> String {
        if let custom = customCategories.first(where: { $0.name == name }) { return custom.icon }
        return CategoryStyle.icon(for: name)
    }
    
    private func getCategoryColor(_ name: String) -> Color {
        if let custom = customCategories.first(where: { $0.name == name }) { return Color(hex: custom.colorHex) }
        return CategoryStyle.color(for: name)
    }
}



