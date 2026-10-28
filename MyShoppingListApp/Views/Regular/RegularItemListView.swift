
import SwiftUI

// MARK: - Model

struct RecurringItem: Identifiable {
    let id = UUID()
    var name: String
    var quantity: String
    var frequencyLabel: String   // 例：毎週 / 隔週 / 毎月1日
    var isPriority: Bool = false
    var isActive: Bool = true
    
    /// 名前の下に表示する文字（頻度と、優先の場合は「優先」）
    var subtitle: String {
        isPriority ? "\(frequencyLabel) ・ 優先" : frequencyLabel
    }
}

// MARK: - Dummy Data

extension RecurringItem {
    static let samples: [RecurringItem] = [
        RecurringItem(name: "牛乳", quantity: "1本", frequencyLabel: "毎週", isPriority: true),
        RecurringItem(name: "卵", quantity: "10個", frequencyLabel: "毎週"),
        RecurringItem(name: "トイレットペーパー", quantity: "1パック", frequencyLabel: "毎月1日"),
        RecurringItem(name: "ヨーグルト", quantity: "2個", frequencyLabel: "隔週"),
        RecurringItem(name: "洗剤", quantity: "1個", frequencyLabel: "毎月15日"),
        RecurringItem(name: "ミネラルウォーター", quantity: "1箱", frequencyLabel: "毎週", isActive: false)
    ]
}

// MARK: - Row

struct RecurringItemRow: View {
    let item: RecurringItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 8) {
                Text(item.name)
                    .foregroundStyle(item.isActive ? .primary : .secondary)
                Text(item.quantity)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Text(item.subtitle)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Screen

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
            } header: {
                Text("有効")
            } footer: {
                Text("有効なアイテムは、指定した日に自動でリストへ追加されます。")
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
