
import SwiftUI
import SwiftData

/// 開くシートの判定（登録 or 編集）
enum FrequentItemSheet: Identifiable {
    case register
    case edit(FrequentItem)
    
    var id: String {
        switch self {
        case .register: return "register"
        case .edit(let item): return "edit-\(item.id)"
        }
    }
}

/// よく買うもの一覧（選んで、まとめてリストに追加する画面）
struct FrequentItemListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(FolderNode.rootsDescriptor) private var roots: [FolderNode]
    @Query(sort: \FrequentItem.createdAt) private var items: [FrequentItem]
    @Environment(ToastCenter.self) private var toast
    
    @State private var selection: Set<UUID> = []
    @State private var activeSheet: FrequentItemSheet?
    @State private var editMode: EditMode = .inactive
    
    @State private var itemToDelete: FrequentItem?
    @State private var deleteMessage = ""
    @State private var showDeleteAlert = false
    
    /// 選択中のアイテム（削除などで存在しなくなった id は数えない）
    private var selectedItems: [FrequentItem] {
        items.filter { selection.contains($0.id) && hasDestination($0) }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(items) { item in
                        row(item)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .environment(\.editMode, $editMode)
            .contentMargins(.bottom, 80, for: .scrollContent)   // 浮かぶボタンと重ならないよう、下に余白を足す
            .navigationTitle("よく買うもの")
            .navigationBarTitleDisplayMode(.large)
            .overlay {
                if items.isEmpty {
                    EmptyStateView(
                        systemImage: "",
                        title: "アイテムがありません",
                        message: "「よく買うもの」を追加しましょう",
                        buttonTitle: "追加"
                    ) {
                        activeSheet = .register
                    }
                }
            }
            .overlay(alignment: .bottomTrailing) { addButton }
            .animation(.easeOut(duration: 0.12), value: selectedItems.isEmpty)
            .toolbar {
                //            ToolbarItem(placement: .topBarLeading) {
                //                EditButton()
                //            }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        activeSheet = .register
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onChange(of: editMode) { _, _ in selection.removeAll() }   // 編集モードの切り替え時は、選択をクリア
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .register:
                    FrequentItemFormView()
                case .edit(let item):
                    FrequentItemFormView(item: item)
                }
            }
            .alert("よく買うものを削除しますか？", isPresented: $showDeleteAlert) {
                Button("キャンセル", role: .cancel) {
                    itemToDelete = nil
                }
                Button("削除", role: .destructive) {
                    if let item = itemToDelete {
                        selection.remove(item.id)   // 選択中だった場合は、選択からも外す
                        modelContext.delete(item)
                    }
                    itemToDelete = nil
                }
            } message: {
                Text(deleteMessage)
            }
        }
    }
    
    // MARK: Row
    
    private func row(_ item: FrequentItem) -> some View {
        let isSelected = selection.contains(item.id)
        let canAdd = hasDestination(item)
//        let inList = isInList(item)
        
        return Button {
            if editMode.isEditing {
                activeSheet = .edit(item)
            } else if !canAdd {
                return   // 追加先がない行は選べない
            } else if isSelected {
                selection.remove(item.id)
            } else {
                selection.insert(item.id)
            }
        } label: {
            HStack(spacing: 12) {
                if !editMode.isEditing {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
//                        .opacity(inList ? 0.35 : 1)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
//                        .foregroundStyle(inList ? .secondary : .primary)
                    Text(folderNames(for: item))
                        .font(.footnote)
                        .foregroundStyle(canAdd ? Color.secondary : Color.red)
                }
                
                Spacer()
                
//                if inList {
//                    Text("リストにあります")
//                        .font(.caption)
//                        .foregroundStyle(.secondary)
//                        .padding(.horizontal, 6)
//                        .padding(.vertical, 2)
//                        .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 5))
//                }
                if item.isPriority {
                    Image(systemName: "exclamationmark")
                        .bold()
                        .foregroundStyle(Color.red)
                }
            }
            .padding(.vertical, 2)
            .contentShape(Rectangle())
            .opacity(canAdd || editMode.isEditing ? 1 : 0.4)
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
//        .disabled(inList && !editMode.isEditing)   // すでにリストにあるものは選べない（編集は可能）
    }
    
    // MARK: Floating button / empty / toast
    
    /// 右下に浮かぶ「リストに追加」ボタン（選んだ件数つき）。何も選んでいない時は出さない
    @ViewBuilder
    private var addButton: some View {
        if !selectedItems.isEmpty && !editMode.isEditing {
            Button(action: addSelectedToList) {
                HStack(spacing: 10) {
                    Text("リストに追加")
                    Text("\(selectedItems.count)")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color.accentColor)
                        .frame(minWidth: 28, minHeight: 28)
                        .background(.white, in: Capsule())
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.leading, 20)
                .padding(.trailing, 8)
                .padding(.vertical, 8)
                .background(Color.accentColor, in: Capsule())
                .shadow(color: .black.opacity(0.28), radius: 8, y: 4)
            }
            .padding(16)
            .transition(.opacity)
        }
    }
    
    // MARK: Logic
    
    /// 追加先のフォルダ名（フォルダが削除されている場合は除く）
    private func folderNames(for item: FrequentItem) -> String {
        let names = item.folderIDs
            .compactMap { roots.node(withID: $0)?.name }
            .sorted()
        return names.isEmpty ? "追加先なし" : names.joined(separator: "、")
    }
    
    /// 追加先のフォルダに、同じ名前の未完了アイテムがすでにあるか
//    private func isInList(_ item: FrequentItem) -> Bool {
//        item.folderIDs
//            .compactMap { folders.node(withID: $0) }
//            .contains { node in
//                node.items.contains { $0.name == item.name && !$0.isDone }
//            }
//    }
    
    /// 追加先のフォルダが、1つでも残っているか
    private func hasDestination(_ item: FrequentItem) -> Bool {
        item.folderIDs.contains { roots.node(withID: $0) != nil }
    }
    
    /// 選んだアイテムを、それぞれの追加先フォルダに追加する（フォルダごとに別のアイテムとして作る）
    private func addSelectedToList() {
        let chosen = selectedItems
        for item in chosen {
            for folderID in item.folderIDs {
                guard let node = roots.node(withID: folderID) else { continue }
                node.addItem(name: item.name, isPriority: item.isPriority, in: modelContext)
            }
        }
        
        withAnimation { selection.removeAll() }
        toast.show("\(chosen.count)件をリストに追加しました")
    }
    
    /// 削除の確認アラートを出す
    /// 本文は、先に文字にして持っておく（削除したあとの画面の更新で、消えたアイテムを読まないため）
    private func requestDelete(_ item: FrequentItem) {
        itemToDelete = item
        deleteMessage = "「\(item.name)」を、よく買うものから削除します。すでにリストに追加されたアイテムは、そのまま残ります。"
        showDeleteAlert = true
    }
}

//MARK: - Preview
#Preview("一覧") {
    NavigationStack { FrequentItemListView() }
        .modelContainer(PreviewData.container())
        .toastHost(ToastCenter())
        .tint(Color(red: 0.18, green: 0.55, blue: 0.37))
}

#Preview("登録なし") {
    NavigationStack { FrequentItemListView() }
        .modelContainer(PreviewData.container(withSamples: false))
        .toastHost(ToastCenter())
        .tint(Color(red: 0.18, green: 0.55, blue: 0.37))
}
