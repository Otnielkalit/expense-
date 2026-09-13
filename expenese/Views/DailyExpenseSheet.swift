import SwiftUI
import SwiftData

struct DailyExpenseSheet: View {
    let date: Date
    let expenses: [Expense]
    let customCategories: [Category]
    @Environment(\.dismiss) private var dismiss
    
    private var headerDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter
    }
    
    private var totalExpense: Double {
        expenses.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag Indicator space
            Spacer().frame(height: 20)
            
            // Header
            HStack {
                Spacer()
                Text(headerDateFormatter.string(from: date))
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.textDark)
                    .padding(.leading, 32)
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 32, height: 32)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            
            // Transaction List
            ScrollView {
                VStack(spacing: 0) {
                    if expenses.isEmpty {
                        Text("No records found.")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.gray)
                            .padding(.top, 40)
                    } else {
                        Divider().padding(.horizontal, 24)
                        
                        ForEach(Array(expenses.enumerated()), id: \.element.id) { index, expense in
                            transactionRow(
                                icon: getCategoryIcon(expense.category),
                                color: getCategoryColor(expense.category),
                                name: expense.desc.isEmpty ? expense.category : expense.desc,
                                amount: (expense.isExpense ? "-" : "+") + ReportFormat.rupiah(expense.amount),
                                isExpense: expense.isExpense
                            )
                            
                            Divider().padding(.horizontal, 24)
                        }
                        
                        // Total Row
                        HStack {
                            Spacer()
                            Text("Total")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.textDark)
                            Text("-"+ReportFormat.rupiah(totalExpense))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.expenseRed)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 24)
                    }
                }
            }
        }
        .background(Theme.bgApp)
        .presentationDragIndicator(.visible)
        .presentationDetents([.medium, .large])
        .presentationCornerRadius(30)
    }
    
    private func transactionRow(icon: String, color: Color, name: String, amount: String, isExpense: Bool = true) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(color)
                .clipShape(Circle())
            
            Text(name)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(Theme.textDark)
            
            Spacer()
            
            Text(amount)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(isExpense ? Theme.expenseRed : Theme.incomePurple)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
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
