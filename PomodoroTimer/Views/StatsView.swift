import SwiftUI
import Charts

// MARK: - 统计页面

struct StatsView: View {

    @EnvironmentObject var store: DataStore

    private enum StatRange: String, CaseIterable {
        case day = "日", week = "周", month = "月", year = "年"
    }

    @State private var selectedRange: StatRange = .day

    // MARK: - 分类颜色

    private let categoryColors: [Color] = [
        Color.blue, Color.green, Color.purple, Color.orange,
        Color.pink, Color.teal, Color.indigo, Color.mint, Color.cyan,
    ]

    private func color(for category: String) -> Color {
        let idx = store.categories.firstIndex(of: category) ?? 0
        return categoryColors[idx % categoryColors.count]
    }

    // MARK: Body

    var body: some View {
        VStack(spacing: 16) {
            Picker("范围", selection: $selectedRange) {
                ForEach(StatRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.top, 12)

            chartContent
                .frame(height: 260)
                .padding(.horizontal, 16)

            Spacer()
        }
    }

    // MARK: - 图表分发

    @ViewBuilder
    private var chartContent: some View {
        switch selectedRange {
        case .day:   dayChart
        case .week:  weekChart
        case .month: monthChart
        case .year:  yearChart
        }
    }

    // MARK: - 日视图（每分类一个柱子）

    private var dayChart: some View {
        let stats = store.dailyStats(for: Date())
        if stats.isEmpty { return AnyView(emptyView) }

        let maxM = stats.map { $0.seconds / 60 }.max() ?? 1
        let ceiling = Double(maxM) * 1.25

        return AnyView(
            Chart(stats, id: \.category) { item in
                BarMark(
                    x: .value("分类", item.category),
                    y: .value("时长(分)", item.seconds / 60)
                )
                .foregroundStyle(color(for: item.category))
                .cornerRadius(4)
            }
            .chartYScale(domain: 0...ceiling)
            .chartXAxisLabel("分类")
            .chartYAxisLabel("分钟")
            .chartForegroundStyleScale(domain: store.categories, range: categoryColors)
        )
    }

    // MARK: - 周视图（堆叠）

    private var weekChart: some View {
        let stats = store.weeklyCategoryStats()
        let groupTotals = Dictionary(grouping: stats, by: { $0.timePeriod })
            .mapValues { $0.reduce(0) { $0 + $1.seconds } }
        let maxM = (groupTotals.values.max() ?? 1) / 60
        let ceiling = Double(maxM) * 1.25

        return AnyView(
            Chart(stats) { item in
                BarMark(
                    x: .value("日期", item.timePeriod, unit: .day),
                    y: .value("时长(分)", item.seconds / 60)
                )
                .foregroundStyle(by: .value("分类", item.category))
                .cornerRadius(4)
            }
            .chartYScale(domain: 0...ceiling)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
            .chartXAxisLabel("日期")
            .chartYAxisLabel("分钟")
            .chartForegroundStyleScale(domain: store.categories, range: categoryColors)
            .chartLegend(position: .bottom)
        )
    }

    // MARK: - 月视图（堆叠）

    private var monthChart: some View {
        let stats = store.monthlyCategoryStats()
        let groupTotals = Dictionary(grouping: stats, by: { $0.timePeriod })
            .mapValues { $0.reduce(0) { $0 + $1.seconds } }
        let maxM = (groupTotals.values.max() ?? 1) / 60
        let ceiling = Double(maxM) * 1.25

        return AnyView(
            Chart(stats) { item in
                BarMark(
                    x: .value("周", item.timePeriod, unit: .weekOfYear),
                    y: .value("时长(分)", item.seconds / 60)
                )
                .foregroundStyle(by: .value("分类", item.category))
                .cornerRadius(4)
            }
            .chartYScale(domain: 0...ceiling)
            .chartXAxis {
                AxisMarks(values: .stride(by: .weekOfYear)) { value in
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                }
            }
            .chartXAxisLabel("周")
            .chartYAxisLabel("分钟")
            .chartForegroundStyleScale(domain: store.categories, range: categoryColors)
            .chartLegend(position: .bottom)
        )
    }

    // MARK: - 年视图（堆叠）

    private var yearChart: some View {
        let stats = store.yearlyCategoryStats()
        let groupTotals = Dictionary(grouping: stats, by: { $0.timePeriod })
            .mapValues { $0.reduce(0) { $0 + $1.seconds } }
        let maxM = (groupTotals.values.max() ?? 1) / 60
        let ceiling = Double(maxM) * 1.25

        return AnyView(
            Chart(stats) { item in
                BarMark(
                    x: .value("月份", item.timePeriod, unit: .month),
                    y: .value("时长(分)", item.seconds / 60)
                )
                .foregroundStyle(by: .value("分类", item.category))
                .cornerRadius(4)
            }
            .chartYScale(domain: 0...ceiling)
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { value in
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                }
            }
            .chartXAxisLabel("月份")
            .chartYAxisLabel("分钟")
            .chartForegroundStyleScale(domain: store.categories, range: categoryColors)
            .chartLegend(position: .bottom)
        )
    }

    // MARK: - 空状态

    private var emptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.xaxis")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("暂无数据")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
