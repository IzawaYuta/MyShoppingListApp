
import SwiftUI

// MARK: - Model

/// 定期アイテムモデル
struct RecurringItem: Identifiable {
    let id = UUID()
    var name: String
    var frequencyLabel: String   // 例：毎週 / 隔週 / 毎月1日
    var isPriority: Bool = false
    var isActive: Bool = true
    
    /// 名前の下に表示する文字（頻度と、優先の場合は「優先」）
    var subtitle: String {
        frequencyLabel
    }
}

// MARK: - Dummy Data

/// ダミーデータ
extension RecurringItem {
    static let samples: [RecurringItem] = [
        RecurringItem(name: "牛乳", frequencyLabel: "毎週", isPriority: true),
        RecurringItem(name: "卵", frequencyLabel: "毎週"),
        RecurringItem(name: "トイレットペーパー", frequencyLabel: "毎月1日"),
        RecurringItem(name: "ヨーグルト", frequencyLabel: "隔週"),
        RecurringItem(name: "洗剤", frequencyLabel: "毎月15日"),
        RecurringItem(name: "ミネラルウォーター", frequencyLabel: "毎週", isActive: false)
    ]
}

// MARK: - Row

/// 定期アイテム１つの行の見た目
struct RecurringItemRow: View {
    let item: RecurringItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .foregroundStyle(item.isActive ? .primary : .secondary)
                Text(item.subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if item.isPriority {
                Image(systemName: "exclamationmark")
                    .bold()
                    .foregroundStyle(Color.red)
            }
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 8)
    }
}

// MARK: - Screen

/// メインビュー（定期アイテム一覧リスト）
struct RegularItemListView: View {
    @State private var items = RecurringItem.samples
    @State private var isShowingForm = false
    
    private var activeItems: [RecurringItem] { items.filter { $0.isActive } }
    private var pausedItems: [RecurringItem] { items.filter { !$0.isActive } }
    
    var body: some View {
        List {
            Section {
                ForEach(activeItems) { item in
                    RecurringItemRow(item: item)
                }
                .onDelete { delete(from: activeItems, at: $0) }
            }
            
            if !pausedItems.isEmpty {
                Section("一時停止中") {
                    ForEach(pausedItems) { item in
                        RecurringItemRow(item: item)
                    }
                    .onDelete { delete(from: pausedItems, at: $0) }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("定期アイテム")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingForm = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowingForm) {
            NavigationStack {
                RegularItemInfoView()
            }
        }
    }
    
    /// セクション内の行番号から、元の配列の項目を削除する
    private func delete(from section: [RecurringItem], at offsets: IndexSet) {
        let ids = offsets.map { section[$0].id }
        items.removeAll { ids.contains($0.id) }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RegularItemListView()
    }
    .tint(Color(red: 0.18, green: 0.55, blue: 0.37))
}
