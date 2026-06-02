# 技术规范 — 番茄钟专注学习软件

## 1. 技术栈

| 层级 | 选型 |
|------|------|
| 语言 | Swift 5.9+ |
| UI 框架 | SwiftUI |
| 图表 | Swift Charts |
| 菜单栏 | AppKit (NSStatusBar, NSPopover) |
| 数据持久化 | 本地 JSON (Codable) |
| 通知 | UserNotifications |
| 最低系统 | macOS 14.0 |

## 2. 项目结构

```
PomodoroTimer/
├── PomodoroTimerApp.swift          — 应用入口 + 菜单栏
├── Models/
│   ├── FocusSession.swift          — 专注记录模型
│   └── SessionMode.swift           — 模式枚举
├── Services/
│   └── DataStore.swift             — 数据管理 + 统计
├── Views/
│   ├── ContentView.swift           — Tab 容器
│   ├── TimerView.swift             — 计时页面
│   ├── HistoryView.swift           — 历史记录页面
│   ├── StatsView.swift             — 数据统计页面
│   └── CategoryManagerView.swift   — 分类管理弹窗
├── Components/
│   ├── CircularProgressView.swift  — 圆形进度环
│   └── TimeDisplayView.swift       — 时间数字显示
└── Assets.xcassets                 — 图标与颜色资源
```

## 3. 数据模型

```swift
struct FocusSession: Codable, Identifiable {
    var id: UUID
    var category: String
    var mode: SessionMode
    var startTime: Date
    var duration: TimeInterval       // 实际秒数
    var targetDuration: TimeInterval? // 倒计时目标（nil=正计时）
}

enum SessionMode: String, Codable, CaseIterable {
    case countdown = "倒计时"
    case stopwatch = "正计时"
}
```

## 4. 数据存储

- 文件路径: `/Users/why/Desktop/番茄钟/Data/sessions.json`
- 分类存储: `/Users/why/Desktop/番茄钟/Data/categories.json`
- 格式: UTF-8 JSON，格式化输出（pretty-print）
- 每次写操作覆盖全量（数据量小，性能无问题）

## 5. 架构模式

- **MVVM**: View ↔ ViewModel(DataStore) ↔ Model
- **DataStore**: Singleton + @ObservableObject，全局共享状态
- **计时器**: Timer.publish 驱动 UI 更新，秒级精度

## 6. 状态栏配置

- `LSUIElement = YES`：隐藏 Dock 图标，仅菜单栏
- 图标：SF Symbol `timer` 或自定义番茄图标
- Popover：点击展开，点空白处自动收起

## 7. 通知配置

- 使用 `UNUserNotificationCenter`
- 倒计时结束触发
- 标题："专注完成！"
- 内容：显示分类和时长
