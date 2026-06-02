# 🍅 番茄钟 — macOS 专注学习助手

一款运行在 macOS 菜单栏的番茄钟应用，帮助你记录和管理每次专注学习的时间。

> **PomodoroTimer** is a lightweight macOS menu bar app for focused study sessions. Track your time with countdown or stopwatch modes, categorize your work, and review your productivity with color-coded charts — all without leaving the menu bar.

## 功能

- **倒计时模式** — 默认 25 分钟，支持自定义时长（5/15/25/30/45/60 分钟 + 手动输入）
- **正计时模式** — 从 0 开始累计，手动结束
- **暂停 / 继续** — 专注中途可暂停，继续后从断点接续
- **专注分类** — 预设学习、阅读、编程、背单词等分类，支持自定义增删
- **历史记录** — 按时间倒序展示所有记录，支持按分类筛选和滑动删除
- **数据统计** — 日 / 周 / 月 / 年四个维度的条形图，按分类着色堆叠
- **系统通知** — 倒计时结束提醒、久坐满 1 小时提醒
- **菜单栏常驻** — 不占 Dock 空间，点击图标弹出面板

## 技术栈

| 层级 | 技术 |
|------|------|
| 语言 | Swift 5.9+ |
| UI | SwiftUI + AppKit (NSStatusBar / NSPopover) |
| 图表 | Swift Charts |
| 数据 | 本地 JSON (Codable + FileManager) |
| 通知 | UserNotifications |
| 最低系统 | macOS 14.0 |

## 快速开始

```bash
# 打开 Xcode 项目
open PomodoroTimer/PomodoroTimer.xcodeproj
```

然后在 Xcode 中按 `Cmd + R` 运行。

## 项目结构

```
番茄钟/
├── README.md                         ← 本文件
├── CLAUDE.md                         ← AI 辅助开发指引
├── docs/
│   ├── requirements.md               ← 需求文档
│   ├── technical-spec.md             ← 技术规范
│   ├── design-guidelines.md          ← 设计规范
│   └── execution-plan.md             ← 分阶段执行计划
├── 开发日志/                          ← 每日开发记录
├── Data/                             ← 运行时数据文件
│   ├── sessions.json                 ← 专注记录
│   └── categories.json               ← 分类列表
└── PomodoroTimer/                    ← Xcode 项目
    ├── PomodoroTimerApp.swift        ← 入口 + 菜单栏
    ├── Info.plist
    ├── Models/
    │   └── FocusSession.swift        ← 数据模型
    ├── Services/
    │   └── DataStore.swift           ← 数据管理
    ├── Views/
    │   ├── ContentView.swift         ← Tab 容器
    │   ├── TimerView.swift           ← 计时页
    │   ├── HistoryView.swift         ← 历史页
    │   ├── StatsView.swift           ← 统计页
    │   └── CategoryManagerView.swift ← 分类管理
    └── Components/
        ├── CircularProgressView.swift
        └── TimeDisplayView.swift
```

## 使用说明

1. 启动后菜单栏出现 ⏱ 图标，点击弹出面板
2. **专注** 页：选择分类 → 选择模式 → 设置时长 → 点击「开始专注」
3. **历史** 页：查看所有记录，可按分类筛选、左滑删除
4. **统计** 页：切换日/周/月/年查看专注数据条形图
5. 面板右下角「退出」按钮可关闭应用

## 许可证

MIT

Vamos, WHY!
