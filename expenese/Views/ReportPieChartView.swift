//
//  ReportPieChartView.swift
//  expenese
//
//  Created by Marzandi Zahran Affandi Leta on 11/09/26.
//

import SwiftUI

struct ReportPieChartView: View {
    let categories: [ReportCategoryItem]
    let expenses: [Expense]

    @State private var selectedCategory: ReportCategoryItem?

    var body: some View {
        VStack(spacing: 16) {
            DonutChartView(
                slices: chartSlices,
                selectedID: selectedCategory?.id
            ) { item in
                selectedCategory = item
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: 280)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)

            legend
        }
        .sheet(item: $selectedCategory) { category in
            ReportCategoryDetailSheet(
                category: category,
                expenses: expenses
                    .filter { $0.category == category.name }
                    .sorted { $0.date > $1.date }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .onChange(of: expenses.map(\.id)) { _, _ in
            selectedCategory = nil
        }
    }

    private var chartSlices: [ReportCategoryItem] {
        categories.sorted { $0.amount > $1.amount }
    }

    private var legend: some View {
        VStack(spacing: 8) {
            legendRow(Array(categories.prefix(3)))
            if categories.count > 3 {
                legendRow(Array(categories.dropFirst(3)))
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func legendRow(_ items: [ReportCategoryItem]) -> some View {
        HStack(spacing: 14) {
            ForEach(items) { slice in
                HStack(spacing: 6) {
                    Circle()
                        .fill(slice.color)
                        .frame(width: 8, height: 8)
                    Text(slice.name)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
        }
    }
}

private struct DonutChartView: View {
    let slices: [ReportCategoryItem]
    let selectedID: String?
    let onSelect: (ReportCategoryItem) -> Void

    private let gap: Double = 2
    private let innerRatio: CGFloat = 0.62
    private let explodeDistance: CGFloat = 12
    private let growRadius: CGFloat = 10

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let baseRadius = (side / 2) - explodeDistance - growRadius

            ZStack {
                ForEach(sliceLayout) { layout in
                    DonutSliceView(
                        layout: layout,
                        isSelected: layout.item.id == selectedID,
                        innerRatio: innerRatio,
                        explodeDistance: explodeDistance,
                        growRadius: growRadius,
                        onSelect: { onSelect(layout.item) }
                    )
                }

                ForEach(sliceLayout) { layout in
                    if layout.item.percent >= 10 {
                        percentLabel(
                            layout: layout,
                            isSelected: layout.item.id == selectedID,
                            center: center,
                            radius: baseRadius * 0.81
                        )
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private func percentLabel(
        layout: SliceLayout,
        isSelected: Bool,
        center: CGPoint,
        radius: CGFloat
    ) -> some View {
        let explode = isSelected ? explodeDistance : 0
        let offset = explodeOffset(angle: layout.mid, distance: explode)
        let point = labelPoint(center: center, radius: radius, angle: layout.mid)

        return Text("\(layout.item.percent) %")
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .rotationEffect(.degrees(layout.mid + 90))
            .position(x: point.x + offset.width, y: point.y + offset.height)
            .allowsHitTesting(false)
            .animation(.spring(response: 0.35, dampingFraction: 0.78), value: selectedID)
    }

    private var sliceLayout: [SliceLayout] {
        let total = max(slices.reduce(0) { $0 + $1.sliceWeight }, 1)
        let gapCount = max(slices.count, 1)
        let usable = max(360 - (gap * Double(gapCount)), 1)
        var current = -90.0

        return slices.map { item in
            let sweep = usable * (item.sliceWeight / total)
            let start = current + (gap / 2)
            let end = start + sweep
            let layout = SliceLayout(item: item, start: start, end: end)
            current += sweep + gap
            return layout
        }
    }

    private func explodeOffset(angle: Double, distance: CGFloat) -> CGSize {
        let radians = angle * .pi / 180
        return CGSize(
            width: CGFloat(cos(radians)) * distance,
            height: CGFloat(sin(radians)) * distance
        )
    }

    private func labelPoint(center: CGPoint, radius: CGFloat, angle: Double) -> CGPoint {
        let radians = angle * .pi / 180
        return CGPoint(
            x: center.x + CGFloat(cos(radians)) * radius,
            y: center.y + CGFloat(sin(radians)) * radius
        )
    }
}

private struct DonutSliceView: View {
    let layout: SliceLayout
    let isSelected: Bool
    let innerRatio: CGFloat
    let explodeDistance: CGFloat
    let growRadius: CGFloat
    let onSelect: () -> Void

    private var extra: CGFloat { isSelected ? growRadius : 0 }
    private var explodeOffset: CGSize {
        let explode = isSelected ? explodeDistance : 0
        let radians = layout.mid * .pi / 180
        return CGSize(
            width: CGFloat(cos(radians)) * explode,
            height: CGFloat(sin(radians)) * explode
        )
    }

    var body: some View {
        DonutSliceShape(
            startAngle: layout.start,
            endAngle: layout.end,
            innerRatio: innerRatio,
            extraOuter: extra
        )
        .fill(layout.item.color)
        .shadow(color: isSelected ? layout.item.color.opacity(0.35) : .clear, radius: 8, y: 2)
        .offset(x: explodeOffset.width, y: explodeOffset.height)
        .contentShape(
            DonutSliceShape(
                startAngle: layout.start,
                endAngle: layout.end,
                innerRatio: innerRatio,
                extraOuter: extra
            )
        )
        .onTapGesture(perform: onSelect)
        .zIndex(isSelected ? 1 : 0)
        .animation(.spring(response: 0.35, dampingFraction: 0.78), value: isSelected)
    }
}

private struct SliceLayout: Identifiable {
    var id: String { item.id }
    let item: ReportCategoryItem
    let start: Double
    let end: Double
    var mid: Double { (start + end) / 2 }
}

private struct DonutSliceShape: Shape {
    var startAngle: Double
    var endAngle: Double
    var innerRatio: CGFloat
    var extraOuter: CGFloat

    var animatableData: CGFloat {
        get { extraOuter }
        set { extraOuter = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let baseOuter = min(rect.width, rect.height) / 2 - 22
        let outer = baseOuter + extraOuter
        var path = Path()
        path.addArc(
            center: center,
            radius: outer,
            startAngle: .degrees(startAngle),
            endAngle: .degrees(endAngle),
            clockwise: false
        )
        path.addArc(
            center: center,
            radius: baseOuter * innerRatio,
            startAngle: .degrees(endAngle),
            endAngle: .degrees(startAngle),
            clockwise: true
        )
        path.closeSubpath()
        return path
    }
}

#Preview {
    return ReportPieChartView(
        categories: [],
        expenses: []
    )
    .padding()
}
