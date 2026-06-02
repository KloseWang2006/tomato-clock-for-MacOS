import SwiftUI

// MARK: - 分类管理弹窗

struct CategoryManagerView: View {

    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) private var dismiss

    @State private var newCategoryName = ""

    var body: some View {
        VStack(spacing: 0) {
            // 标题
            HStack {
                Text("管理分类")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button("完成") {
                    dismiss()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 12)

            Divider()

            // 添加新分类
            HStack(spacing: 8) {
                TextField("新分类名称", text: $newCategoryName)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 180)
                    .onSubmit { addNewCategory() }

                Button("添加") {
                    addNewCategory()
                }
                .buttonStyle(.borderedProminent)
                .disabled(newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            Divider()

            // 现有分类列表
            List {
                ForEach(store.categories, id: \.self) { category in
                    HStack {
                        Image(systemName: "tag.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text(category)
                        Spacer()
                        // 统计该分类下的记录数
                        let count = store.sessions.filter { $0.category == category }.count
                        Text("\(count) 条记录")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .onDelete { offsets in
                    for idx in offsets {
                        store.removeCategory(store.categories[idx])
                    }
                }
            }
            .listStyle(.plain)
        }
        .frame(width: 340, height: 380)
    }

    private func addNewCategory() {
        store.addCategory(newCategoryName)
        newCategoryName = ""
    }
}
