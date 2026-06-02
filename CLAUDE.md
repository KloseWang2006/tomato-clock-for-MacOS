# 番茄钟专注学习软件 — CLAUDE.md

## 项目概览

macOS 菜单栏番茄钟应用，SwiftUI + Swift Charts 开发。帮助用户记录和管理专注学习时长。

## 标准文件索引

| 文件 | 路径 | 说明 |
|------|------|------|
| 需求文档 | [docs/requirements.md](docs/requirements.md) | 完整的功能与非功能需求 |
| 技术规范 | [docs/technical-spec.md](docs/technical-spec.md) | 技术栈、数据模型、架构 |
| 设计规范 | [docs/design-guidelines.md](docs/design-guidelines.md) | UI 色彩、排版、组件规范 |
| 执行计划 | [docs/execution-plan.md](docs/execution-plan.md) | 分阶段开发步骤 |
| 开发日志 | [开发日志/](开发日志/) | 每日开发记录 |

## 工作原则

1. **分阶段推进**：严格按照 [docs/execution-plan.md](docs/execution-plan.md) 的顺序，一个阶段完成并验证后再进入下一阶段
2. **不跳步**：每个阶段的验收标准必须通过才能继续
3. **每次只做一件事**：不并行开发多个阶段
4. **先确认后执行**：涉及需求变更或方案调整时，先和用户确认
5. **每阶段结束**：在 [开发日志/](开发日志/) 中新增一条日志，记录完成事项和待办

## 项目路径

- 项目根目录：`/Users/why/Desktop/番茄钟/`
- Xcode 项目：`/Users/why/Desktop/番茄钟/PomodoroTimer/`
- 数据文件：`/Users/why/Desktop/番茄钟/Data/sessions.json`

## 技术速览

- Swift 5.9+ / SwiftUI / Swift Charts
- macOS 14.0+
- NSStatusBar 菜单栏 + NSPopover
- 数据：本地 JSON (Codable + FileManager)
- 通知：UNUserNotificationCenter

## 常见命令

```bash
# 打开 Xcode 项目
open /Users/why/Desktop/番茄钟/PomodoroTimer/PomodoroTimer.xcodeproj

# 查看数据文件
cat /Users/why/Desktop/番茄钟/Data/sessions.json
```

## 对话回复习惯
在末尾说一句“Vamos！”
