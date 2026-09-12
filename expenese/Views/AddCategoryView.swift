//
//  AddCategoryView.swift
//  expenese
//
//  Created by otnielkalit on 12/09/26.
//

import SwiftData
import SwiftUI

struct AddCategoryView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context

    @State private var categoryName: String = ""
    @State private var selectedIcon: String = "cart.fill"
    @State private var selectedColorHex: String = "007AFF"
    @State private var errorMessage: String?

    var onCreated: ((Category) -> Void)? = nil

    private var selectedColor: Color {
        Color(hex: selectedColorHex)
    }

    private var trimmedName: String {
        categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bgApp.ignoresSafeArea()

                VStack(spacing: 24) {
                    previewSection
                    formSection
                    Spacer()
                    saveButton
                }
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Couldn't Save Category", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private var previewSection: some View {
        VStack(spacing: 16) {
            Image(systemName: selectedIcon)
                .font(.system(size: 40))
                .foregroundColor(.white)
                .frame(width: 80, height: 80)
                .background(selectedColor)
                .clipShape(Circle())
                .shadow(color: selectedColor.opacity(0.3), radius: 10, y: 5)

            Text(trimmedName.isEmpty ? "Category Name" : trimmedName)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Theme.textDark)
        }
        .padding(.top, 20)
    }

    private var formSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Name")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.textDark)

                TextField("Enter category name", text: $categoryName)
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(12)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Icon")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.textDark)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(CategoryCatalog.icons, id: \.self) { icon in
                            Button(action: { selectedIcon = icon }) {
                                Image(systemName: icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(selectedIcon == icon ? .white : .gray)
                                    .frame(width: 50, height: 50)
                                    .background(selectedIcon == icon ? selectedColor : Color.white)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Color")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.textDark)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(CategoryCatalog.colors, id: \.hex) { item in
                            Button(action: { selectedColorHex = item.hex }) {
                                Circle()
                                    .fill(item.color)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle().stroke(Color.white, lineWidth: selectedColorHex == item.hex ? 3 : 0)
                                    )
                                    .shadow(color: item.color.opacity(0.3), radius: 5, y: 2)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(24)
        .padding(.horizontal, 16)
    }

    private var saveButton: some View {
        Button(action: saveCategory) {
            Text("Save Category")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(trimmedName.isEmpty ? Color.gray : Color.blue)
                .cornerRadius(16)
        }
        .disabled(trimmedName.isEmpty)
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }

    private func saveCategory() {
        guard !trimmedName.isEmpty else { return }

        if CategoryStore.categoryNamed(trimmedName, in: context) != nil {
            errorMessage = "A category named \"\(trimmedName)\" already exists."
            return
        }

        let category = Category(
            name: trimmedName,
            icon: selectedIcon,
            colorHex: selectedColorHex,
            sortOrder: CategoryStore.nextSortOrder(in: context),
            isPreset: false
        )
        context.insert(category)
        try? context.save()
        onCreated?(category)
        dismiss()
    }
}

extension View {
    func addCategorySheet(
        isPresented: Binding<Bool>,
        onCreated: ((Category) -> Void)? = nil
    ) -> some View {
        sheet(isPresented: isPresented) {
            AddCategoryView(onCreated: onCreated)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}
