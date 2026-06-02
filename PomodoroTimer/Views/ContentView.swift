import SwiftUI

/// TabView 容器：计时 / 历史 / 统计
struct ContentView: View {
    var body: some View {
        VStack(spacing: 0) {
            TabView {
                TimerView()
                    .tabItem {
                        Label("专注", systemImage: "timer")
                    }

                HistoryView()
                    .tabItem {
                        Label("历史", systemImage: "list.bullet.rectangle")
                    }

                StatsView()
                    .tabItem {
                        Label("统计", systemImage: "chart.bar.fill")
                    }
            }

            // 底部关闭按钮
            HStack {
                Spacer()
                Button {
                    NSApp.terminate(nil)
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "power")
                        Text("退出")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 12)
                .padding(.bottom, 6)
            }
        }
        .frame(width: 340, height: 500)
    }
}
