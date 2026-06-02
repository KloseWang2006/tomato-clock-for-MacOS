import Foundation

// MARK: - 计时模式枚举

enum SessionMode: String, Codable, CaseIterable {
    case countdown = "倒计时"
    case stopwatch  = "正计时"
}

// MARK: - 专注记录模型

struct FocusSession: Codable, Identifiable {
    var id: UUID
    var category: String           // 分类名
    var mode: SessionMode          // 计时模式
    var startTime: Date            // 开始时间
    var duration: TimeInterval     // 实际专注秒数
    var targetDuration: TimeInterval? // 倒计时目标秒数，正计时为 nil

    init(
        id: UUID = UUID(),
        category: String,
        mode: SessionMode,
        startTime: Date = Date(),
        duration: TimeInterval = 0,
        targetDuration: TimeInterval? = nil
    ) {
        self.id = id
        self.category = category
        self.mode = mode
        self.startTime = startTime
        self.duration = duration
        self.targetDuration = targetDuration
    }
}

// MARK: - 堆叠图数据点（时间段 × 分类）

struct CategoryStat: Identifiable {
    /// 唯一标识：时间段 + 分类
    var id: String { "\(Int(timePeriod.timeIntervalSince1970))-\(category)" }
    let timePeriod: Date
    let category: String
    let seconds: Int
}
