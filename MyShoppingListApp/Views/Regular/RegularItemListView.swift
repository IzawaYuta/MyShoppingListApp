
import SwiftUI

// MARK: - Model

/// 定期アイテムモデル（登録画面の入力内容 RecurringItemDraft をそのまま持つ）
struct RecurringItem: Identifiable {
    let id = UUID()
    var draft: RecurringItemDraft
    
    var name: String { draft.name }
    var isPriority: Bool { draft.isPriority }
    var isActive: Bool { draft.isActive }
    
    /// 名前の下に表示する頻度（例：毎週 / 隔週 / 毎月1日）
    var subtitle: String {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: draft.startDate)
        let month = calendar.component(.month, from: draft.startDate)
        switch draft.frequency {
        case .monthly: return "毎月\(day)日"
        case .yearly:  return "毎年\(month)月\(day)日"
        default:       return draft.frequency.rawValue
        }
    }
}

// MARK: - Dummy Data

/// ダミーデータ
extension RecurringItem {
    private static func make(_ name: String,
                             _ frequency: RecurrenceFrequency,
                             day: Int = 1,
                             priority: Bool = false,
                             active: Bool = true) -> RecurringItem {
        var draft = RecurringItemDraft()
        draft.name = name
        draft.quantity = ""
        draft.frequency = frequency
        draft.startDate = Calendar.current.date(from: DateComponents(year: 2026, month: 11, day: day)) ?? .now
        draft.isPriority = priority
        draft.isActive = active
        return RecurringItem(draft: draft)
    }
    
    static let samples: [RecurringItem] = [
        make("牛乳", .weekly, priority: true),
        make("卵", .weekly),
        make("トイレットペーパー", .monthly, day: 1),
        make("ヨーグルト", .biweekly),
        make("洗剤", .monthly, day: 15),
        make("ミネラルウォーター", .weekly, active: false)
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
        .contentShape(Rectangle())   // 空白の部分もタップに反応させる
    }
}

// MARK: - Sheet

/// 開くシートの判定（追加 or 編集）
enum RegularItemSheet: Identifiable {
    case add
    case edit(RecurringItem)
    
    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let item): return "edit-\(item.id)"
        }
    }
}

// MARK: - Screen

/// メインビュー（定期アイテム一覧リスト）
struct RegularItemListView: View {
    @State private var items = RecurringItem.samples
    @State private var activeSheet: RegularItemSheet?
    
    private var activeItems: [RecurringItem] { items.filter { $0.isActive } }
    private var pausedItems: [RecurringItem] { items.filter { !$0.isActive } }
    
    var body: some View {
        List {
            Section {
                ForEach(activeItems) { item in
                    row(item)
                }
                .onDelete { delete(from: activeItems, at: $0) }
            }
            
            if !pausedItems.isEmpty {
                Section("一時停止中") {
                    ForEach(pausedItems) { item in
                        row(item)
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
                    activeSheet = .add
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            // RegularItemInfoView が自分で NavigationStack を持っているため、ここでは包まない
            switch sheet {
            case .add:
                RegularItemInfoView { saved in
                    items.append(RecurringItem(draft: saved))
                }
            case .edit(let item):
                RegularItemInfoView(draft: item.draft, title: "定期アイテム編集", isEditing: true) { saved in
                    update(item, with: saved)
                }
            }
        }
    }
    
    /// タップで編集画面を開く行
    private func row(_ item: RecurringItem) -> some View {
        Button {
            activeSheet = .edit(item)
        } label: {
            RecurringItemRow(item: item)
        }
        .buttonStyle(.plain)
    }
    
    /// 編集内容を、元の定期アイテムに反映する
    private func update(_ item: RecurringItem, with draft: RecurringItemDraft) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].draft = draft
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
    .environment(FolderStore())
    .tint(Color(red: 0.18, green: 0.55, blue: 0.37))
}
