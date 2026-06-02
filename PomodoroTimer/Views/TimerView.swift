import SwiftUI
import UserNotifications

// MARK: - 计时页面

struct TimerView: View {

    // MARK: 状态

    @EnvironmentObject var store: DataStore

    @State private var selectedCategory = "学习"
    @State private var selectedMode: SessionMode = .countdown
    @State private var presetMinutes = 25

    // 计时
    @State private var isRunning = false
    @State private var isPaused = false
    @State private var elapsed: TimeInterval = 0
    @State private var startDate: Date?

    @State private var timer: Timer? = nil

    // 久坐提醒
    @State private var sedentaryReminded = false

    // 分类管理弹窗
    @State private var showCategoryManager = false

    /// 预设时长列表（分钟）
    private let presets = [5, 15, 25, 30, 45, 60]

    // MARK: 计算属性

    private var displayedTime: String {
        switch selectedMode {
        case .countdown:
            let remaining = max(0, Double(presetMinutes * 60) - elapsed)
            let m = Int(remaining) / 60
            let s = Int(remaining) % 60
            return String(format: "%02d:%02d", m, s)
        case .stopwatch:
            let m = Int(elapsed) / 60
            let s = Int(elapsed) % 60
            return String(format: "%02d:%02d", m, s)
        }
    }

    private var progress: Double {
        guard selectedMode == .countdown else { return 0 }
        let total = Double(presetMinutes * 60)
        guard total > 0 else { return 0 }
        return min(1, elapsed / total)
    }

    // MARK: Body

    var body: some View {
        VStack(spacing: 16) {

            // 顶部：分类 & 模式
            topControls

            // 圆形进度环 + 时间
            CircularProgressView(progress: progress, mode: selectedMode)
                .overlay {
                    Text(displayedTime)
                        .font(.system(size: 44, weight: .light, design: .monospaced))
                        .foregroundColor(.primary)
                }
                .frame(width: 200, height: 200)

            // 预设时长（仅倒计时）
            if selectedMode == .countdown {
                presetButtons
            }

            Spacer().frame(height: 8)

            // 按钮区
            if isRunning {
                HStack(spacing: 12) {
                    Button(action: togglePause) {
                        Label(isPaused ? "继续" : "暂停",
                              systemImage: isPaused ? "play.fill" : "pause.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 44)
                            .background(isPaused ? Color.orange : Color.yellow,
                                        in: RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)

                    Button(action: endSession) {
                        Label("结束", systemImage: "stop.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 44)
                            .background(Color.red, in: RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            } else {
                Button(action: startSession) {
                    Text("开始专注")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 44)
                        .background(Color.blue, in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .disabled(selectedCategory.isEmpty)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .sheet(isPresented: $showCategoryManager) {
            CategoryManagerView()
                .environmentObject(store)
        }
    }

    // MARK: - 子视图

    private var topControls: some View {
        HStack {
            Picker("分类", selection: $selectedCategory) {
                ForEach(store.categories, id: \.self) { cat in
                    Text(cat).tag(cat)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 100)

            Spacer()

            Picker("模式", selection: $selectedMode) {
                ForEach(SessionMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 140)
            .disabled(isRunning || isPaused)

            Spacer()

            Button {
                showCategoryManager = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.title3)
            }
            .buttonStyle(.plain)
        }
    }

    private var presetButtons: some View {
        HStack(spacing: 6) {
            ForEach(presets, id: \.self) { min in
                Button("\(min)m") {
                    presetMinutes = min
                }
                .font(.caption)
                .fontWeight(presetMinutes == min ? .bold : .regular)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    presetMinutes == min
                        ? Color.blue.opacity(0.2)
                        : Color.clear
                )
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
                .buttonStyle(.plain)
            }

            TextField("", value: $presetMinutes, format: .number)
                .frame(width: 36)
                .font(.caption)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    presetMinutes = max(1, min(180, presetMinutes))
                }
        }
        .padding(.horizontal, 4)
    }

    // MARK: - 计时逻辑

    private func startSession() {
        AppDelegate.requestNotificationPermission()
        isRunning = true
        isPaused = false
        sedentaryReminded = false
        elapsed = 0
        startDate = Date()
        startTimer()
    }

    private func togglePause() {
        if isPaused { resumeTimer() } else { pauseTimer() }
    }

    private func pauseTimer() {
        isPaused = true
        timer?.invalidate()
        timer = nil
    }

    private func resumeTimer() {
        isPaused = false
        startTimer()
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsed += 1

            // 久坐提醒：专注满 1 小时触发（倒计时不满 1h 不触发）
            if !sedentaryReminded, elapsed >= 3600 {
                let shouldRemind: Bool = {
                    if case .countdown = selectedMode {
                        return presetMinutes >= 60
                    }
                    return true // 正计时满 1h 始终提醒
                }()
                if shouldRemind {
                    sendSedentaryReminder()
                    pauseTimer()
                    sedentaryReminded = true
                    return
                }
            }

            // 倒计时归零
            if selectedMode == .countdown,
               elapsed >= Double(presetMinutes * 60) {
                endSession()
                sendCompletionNotification()
            }
        }
    }

    private func sendSedentaryReminder() {
        let content = UNMutableNotificationContent()
        content.title = "久坐提醒"
        content.body = "您已久坐，请起身休息"
        content.sound = .default
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: UUID().uuidString,
                                  content: content, trigger: nil)
        )
    }

    private func endSession() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
        sedentaryReminded = false

        guard let start = startDate, elapsed > 0 else {
            elapsed = 0
            startDate = nil
            return
        }

        let session = FocusSession(
            category: selectedCategory,
            mode: selectedMode,
            startTime: start,
            duration: elapsed,
            targetDuration: selectedMode == .countdown
                ? Double(presetMinutes * 60) : nil
        )
        store.addSession(session)

        elapsed = 0
        startDate = nil
    }

    private func sendCompletionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "专注完成！"
        content.body = "\(selectedCategory) — \(selectedMode.rawValue) \(presetMinutes) 分钟"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}
