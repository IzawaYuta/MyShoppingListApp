
import SwiftUI

// MARK: - Limit

/// フォルダの階層制限
enum FolderLimit {
    static let maxDepth = 3
    /// アイテムを入れられる最小の階層（1階層目にはアイテムを入れない）
    static let itemMinLevel = 2
}

/// 開くシートの判定
/// 複数のsheetを開く場合は、enumで判定するのが簡単
enum ActiveSheet: Identifiable {
    case folder, item
    case editFolder(FolderNode)
    
    var id: String {
        switch self {
        case .folder: return "folder"
        case .item: return "item"
        case .editFolder(let node): return "edit-\(node.id)"
        }
    }
}

// MARK: - Model

/// フォルダのアイコンの色
struct FolderTint {
    let background: Color
    let foreground: Color
    
    static let palette: [FolderTint] = [
        FolderTint(background: Color(red: 0.86, green: 0.95, blue: 0.90), foreground: Color(red: 0.12, green: 0.48, blue: 0.31)),
        FolderTint(background: Color(red: 0.86, green: 0.91, blue: 0.98), foreground: Color(red: 0.18, green: 0.37, blue: 0.66)),
        FolderTint(background: Color(red: 0.98, green: 0.90, blue: 0.83), foreground: Color(red: 0.63, green: 0.31, blue: 0.05)),
        FolderTint(background: Color(red: 0.97, green: 0.87, blue: 0.90), foreground: Color(red: 0.65, green: 0.23, blue: 0.36)),
        FolderTint(background: Color(red: 1.00, green: 0.95, blue: 0.81), foreground: Color(red: 0.54, green: 0.42, blue: 0.00))
    ]
}

/// フォルダ。子フォルダと、そのフォルダ直下の買うものアイテムを持つ
/// （ShoppingItem は ShoppingListView.swift のものを使用）
/// フォルダ（子フォルダ・アイテム含む）データ
@Observable
final class FolderNode: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var tint: FolderTint
    var customIcon: CustomIconFolder?
    var children: [FolderNode]
    var items: [ShoppingItem]
    
    init(name: String, tint: FolderTint, customIcon: CustomIconFolder? = nil, children: [FolderNode] = [], items: [ShoppingItem] = []) {
        self.name = name
        self.tint = tint
        self.customIcon = customIcon
        self.children = children
        self.items = items
    }
    
    /// Imageの代わりに表示する頭文字（画像対応時に差し替え）
    var initial: String { String(name.prefix(1)) }
    
    /// 子フォルダ内も含めたアイテム数
    var totalItemCount: Int {
        items.count + children.reduce(0) { $0 + $1.totalItemCount }
    }
    
    static func == (lhs: FolderNode, rhs: FolderNode) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

/// 画面遷移用。level はそのフォルダの階層（1〜maxDepth）
struct FolderRoute: Hashable {
    let node: FolderNode
    let level: Int
    
    /// このフォルダの中に、さらにフォルダを作成できるか
    var canAddFolder: Bool { level < FolderLimit.maxDepth }
    var canHoldItems: Bool { level >= FolderLimit.itemMinLevel }
}

// MARK: - Dummy Data

/// ダミーデータ
@Observable
final class FolderStore {
    var roots: [FolderNode] = FolderStore.sample()
    
    private static func sample() -> [FolderNode] {
        let p = FolderTint.palette
        
        let vegetables = FolderNode(
            name: "野菜・果物", tint: p[0],
            children: [
                FolderNode(name: "葉物野菜", tint: p[0], items: [
                       ShoppingItem(name: "ほうれん草", isDone: true),
                       ShoppingItem(name: "キャベツ")
                ]),
                FolderNode(name: "根菜", tint: p[2], items: [
                    ShoppingItem(name: "にんじん")
                ]),
                FolderNode(name: "果物", tint: p[3], items: [
                    ShoppingItem(name: "バナナ")
                ])
            ],
            items: [ShoppingItem(name: "ミニトマト")]
        )
        
        let food = FolderNode(
            name: "食品", tint: p[0], customIcon: .apple,
            children: [
                vegetables,
                FolderNode(name: "肉・魚", tint: p[3], items: [
                    ShoppingItem(name: "鶏むね肉")
                ]),
                FolderNode(name: "乳製品・卵", tint: p[4], items: [
                    ShoppingItem(name: "牛乳"),
                    ShoppingItem(name: "卵", isDone: true)
                ])
            ]
        )
        
        return [
            food,
            FolderNode(name: "日用品", tint: p[1], children: [
                FolderNode(name: "洗剤・掃除", tint: p[1], items: [ShoppingItem(name: "洗剤")]),
                FolderNode(name: "紙類", tint: p[1])
            ]),
            FolderNode(name: "飲み物", tint: p[2], children: [FolderNode(name: "水・お茶", tint: p[2])]),
            FolderNode(name: "調味料", tint: p[3], children: [FolderNode(name: "基本調味料", tint: p[3])])
        ]
    }
}

/// フォルダのアイコンの見た目
struct FolderImageView: View {
    let node: FolderNode
    
    var body: some View {
        Group {
            if let customIcon = node.customIcon {
                customIcon.image
                    .resizable()
                    .scaledToFit()
                    .background(Color.white)
            } else {
                // imageName がないときは、今までの頭文字タイル
                Text(node.initial)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(node.tint.foreground)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(node.tint.background)
            }
        }
        .frame(width: 36, height: 36)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}


// MARK: - Row

/// フォルダの一つのリストの見た目
struct FolderNodeRow: View {
    let node: FolderNode
    
    var body: some View {
        HStack(spacing: 12) {
            FolderImageView(node: node)
            Text(node.name)
            
            Spacer()
        }
    }
}

/// フォルダの行。通常は画面を開き、編集モード中は編集画面を開く
struct FolderListRow: View {
    let node: FolderNode
    let level: Int
    let onEdit: () -> Void
    @Environment(\.editMode) private var editMode
    
    var body: some View {
        if editMode?.wrappedValue.isEditing == true {
            Button(action: onEdit) {
                HStack {
                    FolderNodeRow(node: node)
                    Image(systemName: "pencil")
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        } else {
            NavigationLink(value: FolderRoute(node: node, level: level)) {
                FolderNodeRow(node: node)
            }
        }
    }
}

// MARK: - 最初の画面（フォルダのみ）

/// メインビュー（ホーム画面）
struct HomeView: View {
    @Environment(FolderStore.self) private var store
    @State private var activeSheet: ActiveSheet?
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(store.roots) { folder in
                        FolderListRow(node: folder, level: 1) {
                            activeSheet = .editFolder(folder)
                        }
                    }
                    .onDelete { store.roots.remove(atOffsets: $0) }
                }
            }
            .listStyle(.insetGrouped)
            .environment(\.editMode, $editMode)
            .navigationTitle("カテゴリー")
            .navigationDestination(for: FolderRoute.self) { route in
                FolderDetailView(route: route)
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(editMode.isEditing ? "完了" : "編集") {
                        withAnimation { editMode = editMode.isEditing ? .inactive : .active }
                    }
                    Button {
                        activeSheet = .folder
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .folder: FolderFormView(mode: .add(parent: nil, level: 0))
                case .editFolder(let folder): FolderFormView(mode: .edit(folder))
                case .item: EmptyView()
                }
            }
        }
    }
}

// MARK: - 2・3階層目（フォルダ＋買うもの）

/// 子フォルダとアイテムのビュー
struct FolderDetailView: View {
    let route: FolderRoute
    @Bindable private var node: FolderNode
    @State private var editMode: EditMode = .inactive
    
//    @State private var isAddingFolder = false
//    @State private var isAddingItem = false
    @State private var activeSheet: ActiveSheet?
    @State private var newName = ""
    
    @Environment(PurchaseStore.self) private var purchaseStore
    @State private var showTrashAlert = false
    
    private var completedCount: Int { node.items.filter { $0.isDone }.count }
    
    init(route: FolderRoute) {
        self.route = route
        self._node = Bindable(route.node)
    }
    
    var body: some View {
        List {
            // 子フォルダ（最大階層のフォルダには子フォルダがないため表示されない）
            if route.canAddFolder && !node.children.isEmpty {
                Section("フォルダ") {
                    ForEach(node.children) { child in
                        FolderListRow(node: child, level: route.level + 1) {
                            activeSheet = .editFolder(child)
                        }
                    }
                    .onDelete { node.children.remove(atOffsets: $0) }
                }
            }
            
            if route.canHoldItems {
                Section {
                    ForEach($node.items.filter { !$0.wrappedValue.isDone }) { $item in
                        ItemRow(item: $item)
                    }
                    .onDelete { delete(at: $0, done: false) }
                } header: {
                    Text("買うもの")
                } footer: {
                    if !route.canAddFolder {
                        Text("フォルダは\(FolderLimit.maxDepth)階層までです。")
                    }
                }
                
                if completedCount > 0 {
                    Section("完了済み") {
                        ForEach($node.items.filter { $0.wrappedValue.isDone }) { $item in
                            ItemRow(item: $item)
                        }
                        .onDelete { delete(at: $0, done: true) }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .environment(\.editMode, $editMode)
        .navigationTitle(node.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(editMode.isEditing ? "完了" : "編集") {
                    withAnimation { editMode = editMode.isEditing ? .inactive : .active }
                }
                if route.canHoldItems {
                    Button {
                        showTrashAlert = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .disabled(completedCount == 0)
                }
                addMenu
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .folder: FolderFormView(mode: .add(parent: node, level: route.level))
            case .item:   ItemInfoView(currentFolder: node)
            case .editFolder(let folder): FolderFormView(mode: .edit(folder))
            }
        }
        .alert("完了済みを削除しますか？", isPresented: $showTrashAlert) {
            Button("キャンセル", role: .cancel) { }
            Button("削除", role: .destructive) { archiveCompleted() }
        } message: {
            Text("完了済みの\(completedCount)件を、リストから削除して購入履歴に移します。")
        }
    }
    
    /// 最大階層より下には「フォルダを追加」を出さない
    /// フォルダまたはアイテムの追加用plusボタン
    @ViewBuilder
    private var addMenu: some View {
        if route.canAddFolder && route.canHoldItems {
            // 2階層目：フォルダもアイテムも追加できる
            Menu {
                Button("フォルダを追加", systemImage: "folder.badge.plus") { activeSheet = .folder }
                Button("アイテムを追加", systemImage: "plus") { activeSheet = .item }
            } label: {
                Image(systemName: "plus")
            }
        } else if route.canAddFolder {
            // 1階層目：フォルダだけ
            Button { activeSheet = .folder } label: { Image(systemName: "plus") }
        } else {
            // 3階層目：アイテムだけ
            Button { activeSheet = .item } label: { Image(systemName: "plus") }
        }
    }
    
    /// フォルダ追加用ボタン
    private func addFolder() {
        let name = newName.trimmingCharacters(in: .whitespaces)
        newName = ""
        guard !name.isEmpty, route.canAddFolder else { return }
        let tint = FolderTint.palette[node.children.count % FolderTint.palette.count]
        node.children.append(FolderNode(name: name, tint: tint))
    }
    
    /// アイテム追加用ボタン
    private func addItem() {
        let name = newName.trimmingCharacters(in: .whitespaces)
        newName = ""
        guard !name.isEmpty else { return }
        node.items.append(ShoppingItem(name: name))
    }
    
    /// 完了済みのアイテムを購入履歴に移して、リストから削除する
    private func archiveCompleted() {
        let records = node.items.filter { $0.isDone }.map { item in
            PurchaseRecord(
                name: item.name,
                folderName: node.name,
                purchasedAt: item.purchasedAt ?? .now,
                folderID: node.id,
                isPriority: item.isPriority
            )
        }
        withAnimation {
            purchaseStore.records.append(contentsOf: records)
            node.items.removeAll { $0.isDone }
        }
    }
    
    /// 表示している行の番号を、元の配列のアイテムに戻して削除する
    private func delete(at offsets: IndexSet, done: Bool) {
        let visible = node.items.filter { $0.isDone == done }
        let ids = offsets.map { visible[$0].id }
        node.items.removeAll { ids.contains($0.id) }
    }
}

// MARK: - Preview

#Preview {
    HomeView()
        .environment(FolderStore())
        .environment(PurchaseStore())                
        .tint(Color(red: 0.18, green: 0.55, blue: 0.37))
}
