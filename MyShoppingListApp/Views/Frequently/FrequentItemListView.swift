
import SwiftUI

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
    @Environment(FolderStore.self) private var folders
    @Environment(FrequentItemStore.self) private var store
    
    @State private var selection: Set<UUID> = []
    @State private var activeSheet: FrequentItemSheet?
    @State private var editMode: EditMode = .inactive
    @State private var toastText: String?
    
    /// 選択中のアイテム（削除などで存在しなくなった id は数えない）
    private var selectedItems: [FrequentItem] {
        store.items.filter { selection.contains($0.id) }
    }
    
    var body: some View {
        List {
            Section {
                ForEach(store.items) { item in
                    row(item)
                }
                .onDelete { store.items.remove(atOffsets: $0) }
            } header: {
                Text("追加したいものを選んでください")
                    .textCase(nil)
            }
        }
        .listStyle(.insetGrouped)
        .environment(\.editMode, $editMode)
        .contentMargins(.bottom, 80, for: .scrollContent)   // 浮かぶボタンと重ならないよう、下に余白を足す
        .navigationTitle("よく買うもの")
        .navigationBarTitleDisplayMode(.large)
        .overlay { if store.items.isEmpty { emptyState } }
        .overlay(alignment: .bottomTrailing) { addButton }
        .overlay(alignment: .top) { toast }
        .animation(.easeOut(duration: 0.12), value: selectedItems.isEmpty)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
            }
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
                FrequentItemFormView { saved in
                    store.items.append(saved)
                }
            case .edit(let item):
                FrequentItemFormView(item: item) { saved in
                    if let index = store.items.firstIndex(where: { $0.id == saved.id }) {
                        store.items[index] = saved
                    }
                }
            }
        }
    }
    
    // MARK: Row
    
    private func row(_ item: FrequentItem) -> some View {
        let isSelected = selection.contains(item.id)
//        let inList = isInList(item)
        
        return Button {
            if editMode.isEditing {
                activeSheet = .edit(item)
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
                        .foregroundStyle(.secondary)
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
        }
        .buttonStyle(.plain)
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
    
    /// 登録がない時の表示
    private var emptyState: some View {
        ContentUnavailableView {
            Label("まだ登録がありません", systemImage: "plus.circle")
        } description: {
            Text("よく買うものを登録すると、ここから選んで、まとめてリストに追加できます。")
        } actions: {
            Button("よく買うものを登録") { activeSheet = .register }
                .buttonStyle(.borderedProminent)
        }
    }
    
    /// 追加したことを知らせる、短いメッセージ
    @ViewBuilder
    private var toast: some View {
        if let toastText {
            Text(toastText)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.thinMaterial, in: Capsule())
                .shadow(radius: 4)
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
    
    // MARK: Logic
    
    /// 追加先のフォルダ名（フォルダが削除されている場合は除く）
    private func folderNames(for item: FrequentItem) -> String {
        let names = item.folderIDs
            .compactMap { folders.node(withID: $0)?.name }
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
    
    /// 選んだアイテムを、それぞれの追加先フォルダに追加する（フォルダごとに別のアイテムとして作る）
    private func addSelectedToList() {
        let chosen = selectedItems
        for item in chosen {
            for folderID in item.folderIDs {
                guard let node = folders.node(withID: folderID) else { continue }
                node.items.append(ShoppingItem(name: item.name, isPriority: item.isPriority))
            }
        }
        
        withAnimation {
            selection.removeAll()
            toastText = "\(chosen.count)件をリストに追加しました"
        }
        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation { toastText = nil }
        }
    }
}

// MARK: - Preview

#Preview("一覧") {
    let folders = FolderStore()
    return NavigationStack { FrequentItemListView() }
        .environment(folders)
        .environment(FrequentItemStore.sample(folders: folders))
        .tint(Color(red: 0.18, green: 0.55, blue: 0.37))
}

#Preview("登録なし") {
    NavigationStack { FrequentItemListView() }
        .environment(FolderStore())
        .environment(FrequentItemStore())
        .tint(Color(red: 0.18, green: 0.55, blue: 0.37))
}
