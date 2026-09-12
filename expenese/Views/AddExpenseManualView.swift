//
//  AddExpenseManualView.swift
//  expenese
//
//  Created by otnielkalit on 11/09/26.
//

import SwiftUI
import SwiftData

struct AddExpenseManualView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var customCategories: [ExpenseCategory]
    @Environment(\.dismiss) var dismiss
    @State private var amountText: String = ""
    @State private var descriptionText: String = ""
    @State private var selectedCategory: String = "Food & Beverage"
    @State private var selectedMethod: String = "Cash"
    @State private var isExpense: Bool = true
    @State private var showDatePicker = false
    @State private var selectedDate = Date()
    @State private var showAddCategoryModal = false
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 0) {
                customHeader
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        VStack(spacing: 8) {
                            Button(action: { showDatePicker = true }) {
                                Text(formatHeaderDate(selectedDate))
                                    .font(.system(size: 16))
                                    .foregroundColor(.primary)
                            }
                            
                            HStack(alignment: .center, spacing: 4) {
                                Text("Rp")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.primary)
                            
                                TextField("0", text: $amountText)
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.primary)
                                    .keyboardType(.numberPad)
                                    .onChange(of: amountText) { oldValue, newValue in
                                        var filtered = newValue.filter { "0123456789".contains($0) }
                                        while filtered.hasPrefix("0") && filtered.count > 1 {
                                            filtered.removeFirst()
                                        }
                                        if filtered != newValue {
                                            amountText = filtered
                                        }
                                    }
                            }.padding(.horizontal, 24)
                        }
                        
                        VStack(alignment: .leading, spacing: 24) {
                            
                            if isExpense {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Category")
                                        .font(.system(size: 16, weight: .bold))
                                    
                                    Menu {
                                        Button(action: { selectedCategory = "Food & Beverage" }) {
                                            Label("Food & Beverage", systemImage: "fork.knife")
                                        }
                                        Button(action: { selectedCategory = "Transportation" }) {
                                            Label("Transportation", systemImage: "car.fill")
                                        }
                                        Button(action: { selectedCategory = "Utilities" }) {
                                            Label("Utilities", systemImage: "house.fill")
                                        }
                                        Divider()
                                        ForEach(customCategories, id: \.self) { cat in
                                            Button(action: { selectedCategory = cat.name }) {
                                                Label(cat.name, systemImage: cat.icon)
                                            }
                                        }
                                        Divider()
                                        Button(action: { showAddCategoryModal = true }) {
                                            Label("Add Category", systemImage: "plus")
                                        }
                                    } label: {
                                        pickerLabel(icon: getCategoryIcon(selectedCategory), iconBg: getCategoryColor(selectedCategory), text: selectedCategory)
                                    }
                                }
                            }
                       
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description")
                                    .font(.system(size: 16, weight: .bold))
                                
                                TextField("Expense details...", text: $descriptionText, axis: .vertical)
                                    .lineLimit(3...5)
                                    .padding(16)
                                    .background(Color(.tertiarySystemGroupedBackground))
                                    .foregroundColor(.primary)
                                    .cornerRadius(12)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Transaction Method")
                                    .font(.system(size: 16, weight: .bold))
                                
                                HStack(spacing: 12) {
                                    Menu {
                                        Button("Cash", action: { selectedMethod = "Cash" })
                                        Button("QRIS Mandiri", action: { selectedMethod = "QRIS Mandiri" })
                                    } label: {
                                        pickerLabel(icon: "dollarsign", iconBg: .green, text: selectedMethod)
                                    }
                                    
                                    Button(action: {}) {
                                        Image(systemName: "circle.grid.3x3.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.primary)
                                            .frame(width: 50, height: 50)
                                            .background(Color(.secondarySystemGroupedBackground))
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.primary, lineWidth: 2)
                                            )
                                    }
                                }
                            }
                            
                        }
                        .padding(24)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(24)
                        .padding(.horizontal, 16)
                        .zIndex(1) // Ensure it stays above other elements for dropdown
                        
                        // Save Button
                        Button(action: {
                            // Hitung nominal (hapus titik agar bisa dikonversi ke Double)
                            let cleanAmount = amountText.replacingOccurrences(of: ".", with: "")
                            let amountDouble = Double(cleanAmount) ?? 0.0
                            
                            let categoryToSave = isExpense ? selectedCategory : "Income"
                            
                            let newExpense = Expense(
                                amount: amountDouble,
                                category: categoryToSave,
                                paymentMethod: selectedMethod,
                                paymentType: .cash,
                                desc: descriptionText,
                                date: selectedDate,
                                isExpense: isExpense
                            )
                            
                            modelContext.insert(newExpense)
                            try? modelContext.save()
                            dismiss()
                        }) {
                            Text("Save Record")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(amountText.isEmpty || amountText == "0" ? Color.gray : Color.blue)
                                .cornerRadius(16)
                        }
                        .disabled(amountText.isEmpty || amountText == "0")
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showDatePicker) {
            VStack {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                Spacer()
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showAddCategoryModal) {
            AddCategoryView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
    
    private var customHeader: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                    Text("Record")
                        .font(.system(size: 24, weight: .bold))
                }
                .foregroundColor(Theme.textDark)
            }
            
            Spacer()
            
            Menu {
                Button(role: .destructive, action: { isExpense = true }) {
                    Label("Expenses", systemImage: "arrow.up.right")
                }
                Button(action: { isExpense = false }) {
                    Label("Income", systemImage: "arrow.down.left")
                }
            } label: {
                HStack {
                    Image(systemName: isExpense ? "arrow.up.right" : "arrow.down.left")
                    Text(isExpense ? "Expenses" : "Income")
                    Image(systemName: "chevron.down")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isExpense ? Theme.expenseRed : Theme.incomePurple)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(isExpense ? Theme.expenseRed.opacity(0.2) : Theme.incomePurple.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }
    
    private func pickerLabel(icon: String, iconBg: Color, text: String) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 32, height: 32)
                .background(iconBg)
                .clipShape(Circle())
                .foregroundColor(.white)
            
            Text(text)
                .foregroundColor(.primary)
                .padding(.leading, 8)
            
            Spacer()
            
            Image(systemName: "chevron.down")
                .foregroundColor(.primary)
        }
        .padding(12)
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(30)
    }
    
    private func getCategoryIcon(_ category: String) -> String {
        if let custom = customCategories.first(where: { $0.name == category }) {
            return custom.icon
        }
        switch category {
        case "Food & Beverage": return "fork.knife"
        case "Transportation": return "car.fill"
        case "Utilities": return "house.fill"
        default: return "tag.fill"
        }
    }
    
    private func getCategoryColor(_ category: String) -> Color {
        if let custom = customCategories.first(where: { $0.name == category }) {
            return Color(hex: custom.colorHex)
        }
        switch category {
        case "Food & Beverage": return .yellow
        case "Transportation": return Theme.expenseRed
        case "Utilities": return Theme.incomePurple
        default: return .gray
        }
    }
    
    private func formatHeaderDate(_ date: Date) -> AttributedString {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        let dateString = formatter.string(from: date)
        
        let calendar = Calendar.current
        var prefix = ""
        
        if calendar.isDateInToday(date) {
            prefix = "Today, "
        } else if calendar.isDateInYesterday(date) {
            prefix = "Yesterday, "
        } else {
            let weekdayFormatter = DateFormatter()
            weekdayFormatter.dateFormat = "EEEE, "
            prefix = weekdayFormatter.string(from: date)
        }
        
        var attrString = AttributedString("\(prefix)\(dateString)")
        if let range = attrString.range(of: prefix.dropLast(2)) { // omit the comma and space for bolding
            attrString[range].font = .system(size: 16, weight: .bold)
        }
        return attrString
    }
}

