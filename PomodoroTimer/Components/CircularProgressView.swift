import SwiftUI

/// 圆形进度环，倒计时模式显示剩余比例，正计时模式显示完整圆环
struct CircularProgressView: View {

    let progress: Double  // 0 ~ 1
    let mode: SessionMode

    private let lineWidth: CGFloat = 6

    var body: some View {
        ZStack {
            // 背景圆环
            Circle()
                .stroke(
                    Color.blue.opacity(0.12),
                    lineWidth: lineWidth
                )

            // 进度圆环
            if mode == .countdown {
                Circle()
                    .trim(from: 0, to: 1 - progress)
                    .stroke(
                        Color.blue,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.3), value: progress)
            } else {
                // 正计时：完整蓝色圆环（始终满）
                Circle()
                    .trim(from: 0, to: 1)
                    .stroke(
                        Color.blue.opacity(0.5),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            }
        }
    }
}
