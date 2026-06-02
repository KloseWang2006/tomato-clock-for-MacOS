import Foundation

/// 全局数据管理单例，负责专注记录和分类的持久化、增删查。
@MainActor
final class DataStore: ObservableObject {

    // MARK: - 单例

    static let shared = DataStore()

    /// 固定使用公历，避免 cal 在不同系统下的行为差异
    private let cal: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.locale = Locale(identifier: "zh_CN")
        c.firstWeekday = 2 // 周一
        return c
    }()

    // MARK: - 发布属性

    @Published var sessions: [FocusSession] = []
    @Published var categories: [String] = ["学习", "阅读", "编程", "背单词", "其他"]

    // MARK: - 文件路径

    private let dataDir: URL
    private let sessionsURL: URL
    private let categoriesURL: URL

    private init() {
        let desktop = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Desktop/番茄钟/Data")
        self.dataDir = desktop
        self.sessionsURL = desktop.appendingPathComponent("sessions.json")
        self.categoriesURL = desktop.appendingPathComponent("categories.json")

        try? FileManager.default.createDirectory(at: dataDir, withIntermediateDirectories: true)
        load()
    }

    // MARK: - 持久化

    private func load() {
        let fm = FileManager.default
        if fm.fileExists(atPath: sessionsURL.path),
           let data = try? Data(contentsOf: sessionsURL),
           let decoded = try? JSONDecoder().decode([FocusSession].self, from: data) {
            sessions = decoded
        }
        if fm.fileExists(atPath: categoriesURL.path),
           let data = try? Data(contentsOf: categoriesURL),
           let decoded = try? JSONDecoder().decode([String].self, from: data),
           !decoded.isEmpty {
            categories = decoded
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(sessions) {
            try? data.write(to: sessionsURL, options: .atomic)
        }
    }

    private func saveCategories() {
        if let data = try? JSONEncoder().encode(categories) {
            try? data.write(to: categoriesURL, options: .atomic)
        }
    }

    // MARK: - 会话操作

    func addSession(_ session: FocusSession) {
        sessions.insert(session, at: 0)
        save()
    }

    func deleteSession(_ session: FocusSession) {
        sessions.removeAll { $0.id == session.id }
        save()
    }

    func deleteSessions(at offsets: IndexSet) {
        sessions.remove(atOffsets: offsets)
        save()
    }

    // MARK: - 分类操作

    func addCategory(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !categories.contains(trimmed) else { return }
        categories.append(trimmed)
        saveCategories()
    }

    func removeCategory(_ name: String) {
        // 删除分类时，将关联记录归入「其他」
        categories.removeAll { $0 == name }
        for i in sessions.indices where sessions[i].category == name {
            sessions[i].category = "其他"
        }
        save()
        saveCategories()
    }

    // MARK: - 历史查询

    func filteredSessions(category: String? = nil,
                          startDate: Date? = nil,
                          endDate: Date? = nil) -> [FocusSession] {
        sessions.filter { session in
            if let cat = category, session.category != cat { return false }
            if let start = startDate, session.startTime < start { return false }
            if let end = endDate, session.startTime > end { return false }
            return true
        }
    }

    // MARK: - 统计聚合

    /// 某一天各分类时长合计（秒）
    func dailyStats(for date: Date) -> [(category: String, seconds: Int)] {
        let daySessions = sessions.filter {
            cal.isDate($0.startTime, inSameDayAs: date)
        }
        let grouped = Dictionary(grouping: daySessions, by: { $0.category })
        return categories.compactMap { cat in
            guard let list = grouped[cat], !list.isEmpty else { return nil }
            let total = Int(list.reduce(0) { $0 + $1.duration })
            return (cat, total)
        }
    }

    /// 近 7 天每日总时长（秒），最新一天排最后
    func weeklyStats() -> [(date: Date, seconds: Int)] {
        let cal = cal
        return (-6...0).compactMap { offset in
            guard let date = cal.date(byAdding: .day, value: offset, to: Date()) else { return nil }
            let dayStart = cal.startOfDay(for: date)
            let total = sessions.filter {
                cal.isDate($0.startTime, inSameDayAs: dayStart)
            }.reduce(0) { $0 + $1.duration }
            return (dayStart, Int(total))
        }
    }

    /// 近 4 周每周总时长（秒）
    func monthlyStats() -> [(weekStart: Date, seconds: Int)] {
        let cal = cal
        let today = Date()
        return (-3...0).compactMap { offset in
            guard let weekStart = cal.date(byAdding: .weekOfYear, value: offset, to: today) else { return nil }
            let weekStartDay = cal.startOfDay(for: cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: weekStart)) ?? weekStart)
            guard let weekEnd = cal.date(byAdding: .day, value: 7, to: weekStartDay) else { return nil }
            let total = sessions.filter { $0.startTime >= weekStartDay && $0.startTime < weekEnd }
                .reduce(0) { $0 + $1.duration }
            return (weekStartDay, Int(total))
        }
    }

    /// 近 12 月每月总时长（秒）
    func yearlyStats() -> [(monthStart: Date, seconds: Int)] {
        let cal = cal
        let today = Date()
        return (-11...0).compactMap { offset in
            guard let monthStart = cal.date(byAdding: .month, value: offset, to: today) else { return nil }
            let components = cal.dateComponents([.year, .month], from: monthStart)
            guard let normStart = cal.date(from: components),
                  let monthEnd = cal.date(byAdding: .month, value: 1, to: normStart) else { return nil }
            let total = sessions.filter { $0.startTime >= normStart && $0.startTime < monthEnd }
                .reduce(0) { $0 + $1.duration }
            return (normStart, Int(total))
        }
    }

    // MARK: - 堆叠图统计（按 时间段 × 分类）

    /// 近 7 天：每天 × 各分类时长
    func weeklyCategoryStats() -> [CategoryStat] {
        var results: [CategoryStat] = []
        for offset in -6...0 {
            guard let date = cal.date(byAdding: .day, value: offset, to: Date()) else { continue }
            let start = cal.startOfDay(for: date)
            let end = cal.date(byAdding: .day, value: 1, to: start) ?? start
            let daySessions = sessions.filter { $0.startTime >= start && $0.startTime < end }
            let grouped = Dictionary(grouping: daySessions, by: { $0.category })
            var hasAny = false
            for cat in categories {
                let total = Int(grouped[cat]?.reduce(0) { $0 + $1.duration } ?? 0)
                results.append(CategoryStat(timePeriod: start, category: cat, seconds: total))
                if total > 0 { hasAny = true }
            }
            if !hasAny, let firstCat = categories.first {
                results.append(CategoryStat(timePeriod: start, category: firstCat, seconds: 0))
            }
        }
        return results
    }

    /// 近 4 周：每周 × 各分类时长
    func monthlyCategoryStats() -> [CategoryStat] {
        var results: [CategoryStat] = []
        for offset in -3...0 {
            guard let weekDate = cal.date(byAdding: .weekOfYear, value: offset, to: Date()) else { continue }
            let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: weekDate)
            guard let start = cal.date(from: comps),
                  let end = cal.date(byAdding: .day, value: 7, to: start) else { continue }
            let weekSessions = sessions.filter { $0.startTime >= start && $0.startTime < end }
            let grouped = Dictionary(grouping: weekSessions, by: { $0.category })
            var hasAny = false
            for cat in categories {
                let total = Int(grouped[cat]?.reduce(0) { $0 + $1.duration } ?? 0)
                results.append(CategoryStat(timePeriod: start, category: cat, seconds: total))
                if total > 0 { hasAny = true }
            }
            if !hasAny, let firstCat = categories.first {
                results.append(CategoryStat(timePeriod: start, category: firstCat, seconds: 0))
            }
        }
        return results
    }

    /// 近 12 月：每月 × 各分类时长
    func yearlyCategoryStats() -> [CategoryStat] {
        var results: [CategoryStat] = []
        for offset in -11...0 {
            guard let monthDate = cal.date(byAdding: .month, value: offset, to: Date()) else { continue }
            let comps = cal.dateComponents([.year, .month], from: monthDate)
            guard let start = cal.date(from: comps),
                  let end = cal.date(byAdding: .month, value: 1, to: start) else { continue }
            let monthSessions = sessions.filter { $0.startTime >= start && $0.startTime < end }
            let grouped = Dictionary(grouping: monthSessions, by: { $0.category })
            var hasAny = false
            for cat in categories {
                let total = Int(grouped[cat]?.reduce(0) { $0 + $1.duration } ?? 0)
                results.append(CategoryStat(timePeriod: start, category: cat, seconds: total))
                if total > 0 { hasAny = true }
            }
            if !hasAny, let firstCat = categories.first {
                results.append(CategoryStat(timePeriod: start, category: firstCat, seconds: 0))
            }
        }
        return results
    }
}
