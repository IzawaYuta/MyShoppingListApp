
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
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                // 終了日を過ぎたもの（名前が長くても、バッジは消さない）
                VStack(alignment: .leading, spacing: 5) {
                    Text(item.subtitle)
                        .foregroundStyle(.secondary)
                    
                    // 追加先のフォルダが、すべてなくなったとき
                    if item.folderIDs.isEmpty {
                        Text("追加先フォルダが指定されていません")
                            .foregroundStyle(.red)
                    }
                }
                .font(.footnote)
            }
            
            Spacer()
            
            if item.isEnded {
                AutoAddedBadge(textSize: 13, text: "終了")
                    .layoutPriority(1)
            }
            
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
    
    @AppStorage("hasSeenRecurringIntro") private var hasSeenIntro = false
    @State private var showIntro = false
    
    @State private var activeSheet: RegularItemSheet?
    
    @State private var itemToDelete: RecurringItem?
    @State private var deleteMessage = ""
    @State private var showDeleteAlert = false
    
    private var activeItems: [RecurringItem] { items.filter { $0.isActive } }
    private var pausedItems: [RecurringItem] { items.filter { !$0.isActive } }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(activeItems) { item in
                        row(item)
                    }
                } header: {
                    if !items.isEmpty {
                        HStack(spacing: 4) {
                            Text("自動追加されたアイテムには")
                            AutoAddedBadge(textSize: 11)
                            Text("が表示されます。")
                        }
                        .font(.footnote)
                        .textCase(nil)
                    }
                }
                
                if !pausedItems.isEmpty {
                    Section("一時停止中") {
                        ForEach(pausedItems) { item in
                            row(item)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("定期アイテム")
            .navigationBarTitleDisplayMode(.large)
            .overlay {
                if items.isEmpty {
                    EmptyStateView(
                        systemImage: "",
                        title: "アイテムがありません",
                        message: "「定期アイテム」を追加しましょう",
                        buttonTitle: "追加"
                    ) {
                        activeSheet = .add
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        activeSheet = .add
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                if !hasSeenIntro {
                    showIntro = true
                }
            }
            .fullScreenCover(isPresented: $showIntro) {
                RecurringItemIntroView {
                    hasSeenIntro = true
                    showIntro = false
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
                        // 保存する前の内容と比べて、変わったかを調べる
                        let startChanged = !Calendar.current.isDate(item.startDate, inSameDayAs: saved.startDate)
                        let frequencyChanged = item.frequency != saved.frequency
                        let reactivated = !item.isActive && saved.isActive   // 一時停止から有効に戻した
                        
                        item.apply(saved)
                        
                        // 開始日か頻度を変えたとき、有効に戻したときは、今日までの予定日を処理済みにする
                        // （変更した直後に、意図せず追加されないようにするため）
                        if startChanged || frequencyChanged || reactivated {
                            RecurringItemRunner.markProcessedThroughToday(item)
                        }
                    }
                }
            }
            .alert("定期アイテムを削除しますか？", isPresented: $showDeleteAlert) {
                Button("キャンセル", role: .cancel) {
                    itemToDelete = nil
                }
                Button("削除", role: .destructive) {
                    if let item = itemToDelete {
                        modelContext.delete(item)
                    }
                    itemToDelete = nil
                }
            } message: {
                Text(deleteMessage)
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
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                requestDelete(item)
            } label: {
                Label("削除", systemImage: "trash")
            }
            .tint(.red)
        }
    }
    
    /// セクション内の行番号から、元のデータを削除する
    /// 削除の確認アラートを出す
    /// 本文は、先に文字にして持っておく（削除したあとの画面の更新で、消えたアイテムを読まないため）
    private func requestDelete(_ item: RecurringItem) {
        itemToDelete = item
        deleteMessage = "「\(item.name)」を削除すると、自動追加されなくなります。すでにリストに追加されたアイテムは、そのまま残ります。"
        showDeleteAlert = true
    }
}

// MARK: - Preview

#Preview("ダミー") {
    NavigationStack {
        RegularItemListView()
    }
    .modelContainer(PreviewData.container())
    .toastHost(ToastCenter())
    .tint(Color(red: 0.18, green: 0.55, blue: 0.37))
}

#Preview("登録なし") {
    NavigationStack { RegularItemListView() }
        .modelContainer(PreviewData.container(withSamples: false))
        .toastHost(ToastCenter())
        .tint(Color(red: 0.18, green: 0.55, blue: 0.37))
}

