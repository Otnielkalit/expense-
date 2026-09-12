//
//  AddExpenseManualView.swift
//  expenese
//
//  Created by otnielkalit on 11/09/26.
//

import SwiftData
import SwiftUI
import SwiftData

struct AddExpenseManualView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Query(sort: \Category.sortOrder) private var categories: [Category]
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
                                HStack(spacing: 6) {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 16))
                                        .foregroundColor(.blue)
                                    Text(formatHeaderDate(selectedDate))
                                        .font(.system(size: 16))
                                        .foregroundColor(.primary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(12)
                            }
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
                                        ForEach(categories) { category in
                                            Button(action: { selectedCategory = category.name }) {
                                                Label(category.name, systemImage: category.icon)
                                            }
                                        }
                                        Divider()
                                        Button(action: { showAddCategoryModal = true }) {
                                            Label("Add Category", systemImage: "plus")
                                        }
                                    } label: {
                                        pickerLabel(
                                            icon: CategoryCatalog.icon(for: selectedCategory, in: categories),
                                            iconBg: CategoryCatalog.color(for: selectedCategory, in: categories),
                                            text: selectedCategory
                                        )
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
                                    
                                    Button(action: { showDatePicker = true }) {
                                        Image(systemName: "calendar")
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
        .addCategorySheet(isPresented: $showAddCategoryModal) { category in
            selectedCategory = category.name
        }
        .onAppear {
            if CategoryCatalog.find(selectedCategory, in: categories) == nil,
               let first = categories.first {
                selectedCategory = first.name
            }
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

