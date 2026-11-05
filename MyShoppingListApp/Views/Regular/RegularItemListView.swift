
import SwiftUI
import SwiftData

// MARK: - Row

/// 定期アイテム１つの行の見た目（RecurringItem は DataModels.swift のもの）
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
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RecurringItem.createdAt) private var items: [RecurringItem]
    
    @State private var activeSheet: RegularItemSheet?
    
    private var activeItems: [RecurringItem] { items.filter { $0.isActive } }
    private var pausedItems: [RecurringItem] { items.filter { !$0.isActive } }
    
    var body: some View {
        NavigationStack {
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
                        RecurringItemRunner.register(saved, in: modelContext)
                    }
                case .edit(let item):
                    RegularItemInfoView(draft: item.draft, title: "定期アイテム編集", isEditing: true) { saved in
                        item.apply(saved)
                    }
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
    
    /// セクション内の行番号から、元のデータを削除する
    private func delete(from section: [RecurringItem], at offsets: IndexSet) {
        let targets = offsets.map { section[$0] }
        for target in targets {
            modelContext.delete(target)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RegularItemListView()
    }
    .modelContainer(PreviewData.container())
    .toastHost(ToastCenter())
    .tint(Color(red: 0.18, green: 0.55, blue: 0.37))
}
