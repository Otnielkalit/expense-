//
//  ReportCategoryListView.swift
//  expenese
//
//  Created by Marzandi Zahran Affandi Leta on 11/09/26.
//

import SwiftUI

struct ReportCategoryListView: View {
    let categories: [ReportCategoryItem]
    var previewLimit: Int = 3

    @State private var showAllCategories = false

    private let navy = Color(red: 0.16, green: 0.17, blue: 0.24)
    private let amountColor = Color(red: 0.78, green: 0.40, blue: 0.40)
    private let rowBackground = Color(red: 0.94, green: 0.94, blue: 0.97)
    private let showMoreColor = Color(red: 0.25, green: 0.52, blue: 1.0)

    private var visibleCategories: [ReportCategoryItem] {
        if showAllCategories || categories.count <= previewLimit {
            return categories
        }
        return Array(categories.prefix(previewLimit))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            categoryRows
            if categories.count > previewLimit {
                showMoreButton
            }
        }
    }

    private var header: some View {
        HStack(spacing: 8) {
            Text("Category")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(navy)

            Spacer()

            NavigationLink {
                CategoryView()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(showMoreColor)
                    .frame(width: 32, height: 32)
                    .background(showMoreColor.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add Category")
        }
        .padding(.top, 8)
    }

    private var categoryRows: some View {
        VStack(spacing: 10) {
            ForEach(visibleCategories) { item in
                categoryRow(item)
            }
        }
    }

    private func categoryRow(_ item: ReportCategoryItem) -> some View {
        HStack(spacing: 14) {
            Image(systemName: item.icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(item.color)
                .clipShape(Circle())

            Text(item.name)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(navy)
                .lineLimit(1)

            Spacer(minLength: 8)

            Text(ReportFormat.compactRupiah(item.amount))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(amountColor)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(rowBackground)
        .clipShape(Capsule())
    }

    private var showMoreButton: some View {
        HStack {
            Spacer()
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showAllCategories.toggle()
                }
            } label: {
                Text(showAllCategories ? "Show Less" : "Show More")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(showMoreColor)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 4)
    }
}

#Preview {
    NavigationStack {
        ReportCategoryListView(
            categories: ReportDummyData.categories(
                from: ReportDummyData.expenses(for: ReportDummyData.defaultDate, period: .monthly)
            )
        )
        .padding()
    }
}
