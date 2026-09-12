import SwiftUI
import SwiftData

struct EditExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var drafts: [Draft]

    init(drafts: [Draft]) {
        _drafts = State(initialValue: drafts)
    }

    var body: some View {
        NavigationStack {
            Form {
                if drafts.isEmpty {
                    Text("No expenses found.")
                } else {
                    ForEach(Array($drafts.enumerated()), id: \.element.id) { index, $draft in
                        DraftEditorView(index: index + 1, draft: $draft)
                    }
                }
            }
            .navigationTitle("Review Expenses")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save All") {
                        saveAll()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }

    private func saveAll() {
        for draft in drafts {
            let expense = Expense(
                amount: draft.amount,
                category: CategoryCatalog.displayName(for: draft.category),
                paymentMethod: draft.paymentMethod,
                paymentType: draft.paymentType,
                desc: draft.desc,
                date: draft.date,
                isExpense: draft.isExpense
            )
            context.insert(expense)
        }
        try? context.save()
        dismiss()
    }
}

struct DraftEditorView: View {
    let index: Int
    @Binding var draft: Draft
    @Query(sort: \Category.sortOrder) private var categories: [Category]
    @State private var amountText: String
    @State private var showAddCategory = false
    
    init(index: Int, draft: Binding<Draft>) {
        self.index = index
        self._draft = draft
        self._amountText = State(initialValue: String(Int(draft.wrappedValue.amount)))
    }
    
    var body: some View {
        Section(header: Text("Transaction \(index)")) {
            Picker("Transaction Type", selection: $draft.isExpense) {
                Text("Expense").tag(true)
                Text("Income").tag(false)
            }
            .pickerStyle(.segmented)
            .padding(.bottom, 8)
            
            DatePicker("Date", selection: $draft.date, displayedComponents: .date)
            
            HStack(spacing: 16) {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.green)
                    .frame(width: 28)
                
                Text("Amount")
                Spacer()
                TextField("0", text: $amountText)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .onChange(of: amountText) { newValue in
                        draft.amount = Double(newValue) ?? 0
                    }
            }
            
            HStack {
                Image(systemName: CategoryCatalog.icon(for: draft.category, in: categories))
                    .foregroundColor(CategoryCatalog.color(for: draft.category, in: categories))
                    .frame(width: 28)
                Text("Category")
                Spacer()
                Menu {
                    ForEach(categories) { category in
                        Button {
                            draft.category = category.name
                        } label: {
                            Label(category.name, systemImage: category.icon)
                        }
                    }
                    Divider()
                    Button {
                        showAddCategory = true
                    } label: {
                        Label("Add Category", systemImage: "plus")
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(CategoryCatalog.displayName(for: draft.category))
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .addCategorySheet(isPresented: $showAddCategory) { category in
                draft.category = category.name
            }
            .onAppear {
                draft.category = CategoryCatalog.displayName(for: draft.category)
            }
            
            HStack {
                Image(systemName: "creditcard.fill")
                    .foregroundColor(.orange)
                    .frame(width: 28)
                Text("Payment")
                Spacer()
                TextField("Payment Method", text: $draft.paymentMethod)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.secondary)
            }
            
            Picker(selection: $draft.paymentType) {
                ForEach(PaymentType.allCases, id: \.self) { type in
                    Text(type.rawValue.capitalized).tag(type)
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.left.arrow.right")
                        .foregroundColor(.purple)
                        .frame(width: 28)
                    Text("Type")
                }
            }
            
            HStack(alignment: .top) {
                Image(systemName: "note.text")
                    .foregroundColor(.gray)
                    .frame(width: 28)
                    .padding(.top, 7)
                
                TextField("Add a description...", text: $draft.desc, axis: .vertical)
                    .lineLimit(2...4)
                    .padding(.vertical, 4)
            }
        }
    }
}
