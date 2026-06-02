import SwiftUI

// MARK: - 历史记录页面

struct HistoryView: View {

    @EnvironmentObject var store: DataStore

    @State private var filterCategory: String = "全部"
    @State private var searchText = ""

    private var displayedSessions: [FocusSession] {
        var results = store.sessions

        if filterCategory != "全部" {
            results = results.filter { $0.category == filterCategory }
        }

        if !searchText.isEmpty {
            results = results.filter {
                $0.category.localizedCaseInsensitiveContains(searchText)
            }
        }

        return results
    }

    private var filterOptions: [String] {
        ["全部"] + store.categories
    }

    var body: some View {
        VStack(spacing: 0) {
            // 筛选区域
            HStack {
                Picker("分类", selection: $filterCategory) {
                    ForEach(filterOptions, id: \.self) { cat in
                        Text(cat).tag(cat)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 100)

                TextField("搜索", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 120)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            // 列表
            if displayedSessions.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "clock.badge.questionmark")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("暂无专注记录")
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                List {
                    ForEach(displayedSessions) { session in
                        HistoryRow(session: session)
                    }
                    .onDelete { offsets in
                        let ids = offsets.map { displayedSessions[$0].id }
                        for id in ids {
                            if let session = store.sessions.first(where: { $0.id == id }) {
                                store.deleteSession(session)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

// MARK: - 单条记录行

struct HistoryRow: View {

    let session: FocusSession

    private var dateString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "yyyy/MM/dd HH:mm"
        return f.string(from: session.startTime)
    }

    private var durationString: String {
        let m = Int(session.duration) / 60
        let s = Int(session.duration) % 60
        if m > 0 {
            return "\(m) 分 \(s) 秒"
        }
        return "\(s) 秒"
    }

    var body: some View {
        HStack(spacing: 12) {
            // 分类标识
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: "book.fill")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(session.category)
                        .font(.body)
                        .fontWeight(.medium)
                    Text(session.mode.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                Text(dateString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(durationString)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 4)
    }
}
