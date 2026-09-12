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

    private var visibleCategories: [ReportCategoryItem] {
        if showAllCategories || categories.count <= previewLimit {
            return categories
        }
        return Array(categories.prefix(previewLimit))
    }

    private var totalAmount: Double {
        categories.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            categoryRows
            if categories.count > previewLimit {
                seeMoreButton
            }
        }
    }

    private var header: some View {
        HStack {
            Text("All Category")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)

            Spacer()

            (Text("Total ")
                .fontWeight(.regular)
            + Text(ReportFormat.rupiah(totalAmount))
                .fontWeight(.bold))
            .font(.system(size: 16))
            .foregroundColor(.black)
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
        HStack(spacing: 12) {
            Image(systemName: item.icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 34, height: 34)
                .background(Color.white.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text(item.name)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)

            Spacer()

            Text(item.formattedAmount)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(white: 0.38))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var seeMoreButton: some View {
        HStack {
            Spacer()
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showAllCategories.toggle()
                }
            } label: {
                Text(showAllCategories ? "See Less" : "See More")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.25, green: 0.48, blue: 1.0))
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 4)
    }
}

#Preview {
    ReportCategoryListView(
        categories: [
            ReportCategoryItem(id: "Food", name: "Food", amount: 100, sliceWeight: 100, color: .blue, icon: "fork.knife")
        ]
    )
    .padding()
}
