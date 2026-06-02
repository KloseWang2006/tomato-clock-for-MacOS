import SwiftUI

/// 通用时间显示组件，支持指定字体大小
struct TimeDisplayView: View {

    let timeString: String     // "MM:SS"
    var fontSize: CGFloat = 48

    var body: some View {
        Text(timeString)
            .font(.system(size: fontSize, weight: .light, design: .monospaced))
            .foregroundColor(.primary)
    }
}
