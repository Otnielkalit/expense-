//
//  CategoryView.swift
//  expenese
//
//  Created by Marzandi Zahran Affandi Leta on 12/09/26.
//

import SwiftData
import SwiftUI

struct CategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Category.sortOrder) private var categories: [Category]
    @State private var showAddCategory = false

    private let chipBackground = Color(red: 0.94, green: 0.94, blue: 0.97)
    private let addButtonBlue = Color(red: 0.13, green: 0.55, blue: 1.0)

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                if categories.isEmpty {
                    emptyState
                    Spacer()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        CategoryFlowLayout(spacing: 12) {
                            ForEach(categories) { category in
                                categoryChip(category)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                addButton
            }
            .padding(.horizontal, 22)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .navigationTitle(Text("Category"))
        .navigationBarTitleDisplayMode(.inline)
        
        .addCategorySheet(isPresented: $showAddCategory)
    }

    private var header: some View {
        Button(action: { dismiss() }) {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                Text("Category")
                    .font(.system(size: 24, weight: .bold))
                Spacer()
            }
            .foregroundColor(Theme.textDark)
        }
        .buttonStyle(.plain)
        .padding(.top, 6)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "tag")
                .font(.system(size: 32))
                .foregroundColor(.gray.opacity(0.5))
            Text("No categories yet")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 48)
    }

    private var addButton: some View {
        Button {
            showAddCategory = true
        } label: {
            Text("+ Add Category")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(addButtonBlue)
                .clipShape(Capsule())
                .shadow(color: addButtonBlue.opacity(0.28), radius: 10, y: 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
    }

    private func categoryChip(_ category: Category) -> some View {
        HStack(spacing: 8) {
            Image(systemName: category.icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(category.color)
                .clipShape(Circle())

            Text(category.name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Theme.textDark)
                .lineLimit(1)
        }
        .padding(.leading, 6)
        .padding(.trailing, 14)
        .padding(.vertical, 6)
        .background(chipBackground)
        .clipShape(Capsule())
    }
}

nonisolated private struct CategoryFlowLayout: Layout {
    var spacing: CGFloat = 10

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(
            proposal: ProposedViewSize(width: bounds.width, height: bounds.height),
            subviews: subviews
        )
        for (index, origin) in result.origins.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + origin.x, y: bounds.minY + origin.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (origins: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var origins: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            origins.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x - spacing)
        }

        return (origins, CGSize(width: maxX, height: y + rowHeight))
    }
}

#Preview {
    NavigationStack {
        CategoryView()
    }
    .modelContainer(for: [Expense.self, Category.self], inMemory: true)
}
