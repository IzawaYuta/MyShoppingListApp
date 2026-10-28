
import SwiftUI

// MARK: - Limit

enum FolderLimit {
    /// フォルダの最大階層。将来は無制限にする予定のため、判定はこの定数だけに集約している
    static let maxDepth = 3
}

enum ActiveSheet: Identifiable {
    case folder, item
    var id: Self { self }
}

// MARK: - Model

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
}

// MARK: - Dummy Data

@Observable
final class FolderStore {
    var roots: [FolderNode] = FolderStore.sample()
    
    private static func sample() -> [FolderNode] {
        let p = FolderTint.palette
        
        let vegetables = FolderNode(
            name: "野菜・果物", tint: p[0],
            children: [
                FolderNode(name: "葉物野菜", tint: p[0], items: [
                    ShoppingItem(name: "ほうれん草", quantity: "1束", isDone: true),
                    ShoppingItem(name: "キャベツ", quantity: "1玉")
                ]),
                FolderNode(name: "根菜", tint: p[2], items: [
                    ShoppingItem(name: "にんじん", quantity: "3本")
                ]),
                FolderNode(name: "果物", tint: p[3], items: [
                    ShoppingItem(name: "バナナ", quantity: "1房")
                ])
            ],
            items: [ShoppingItem(name: "ミニトマト", quantity: "1パック")]
        )
        
        let food = FolderNode(
            name: "食品", tint: p[0], customIcon: .apple,
            children: [
                vegetables,
                FolderNode(name: "肉・魚", tint: p[3], items: [
                    ShoppingItem(name: "鶏むね肉", quantity: "300g")
                ]),
                FolderNode(name: "乳製品・卵", tint: p[4], items: [
                    ShoppingItem(name: "牛乳", quantity: "1本"),
                    ShoppingItem(name: "卵", quantity: "10個", isDone: true)
                ])
            ],
            items: [ShoppingItem(name: "食パン", quantity: "1袋")]
        )
        
        return [
            food,
            FolderNode(name: "日用品", tint: p[1], items: [ShoppingItem(name: "洗剤", quantity: "1個")]),
            FolderNode(name: "飲み物", tint: p[2]),
            FolderNode(name: "調味料", tint: p[3])
        ]
    }
}

struct FolderImageView: View {
    let node: FolderNode
    
    var body: some View {
        Group {
            if let customIcon = node.customIcon {
                customIcon.image.resizable().scaledToFit()
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

struct FolderNodeRow: View {
    let node: FolderNode
    
    var body: some View {
        HStack(spacing: 12) {
            FolderImageView(node: node)
            Text(node.name)
            
            Spacer()
            
            Text("\(node.totalItemCount)")
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - 最初の画面（フォルダのみ）

struct HomeView: View {
    @State private var store = FolderStore()
    @State private var isAddingFolder = false
    @State private var newFolderName = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(store.roots) { folder in
                        NavigationLink(value: FolderRoute(node: folder, level: 1)) {
                            FolderNodeRow(node: folder)
                        }
                    }
                    .onDelete { store.roots.remove(atOffsets: $0) }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("カテゴリー")
            .navigationDestination(for: FolderRoute.self) { route in
                FolderDetailView(route: route)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAddingFolder = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingFolder) {
                FolderAddView()
            }
        }
        .environment(store)
    }
}

// MARK: - 2・3階層目（フォルダ＋買うもの）

struct FolderDetailView: View {
    let route: FolderRoute
    @Bindable private var node: FolderNode
    
//    @State private var isAddingFolder = false
//    @State private var isAddingItem = false
    @State private var activeSheet: ActiveSheet?
    @State private var newName = ""
    
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
                        NavigationLink(value: FolderRoute(node: child, level: route.level + 1)) {
                            FolderNodeRow(node: child)
                        }
                    }
                    .onDelete { node.children.remove(atOffsets: $0) }
                }
            }
            
            Section {
                ForEach($node.items) { $item in
                    ItemRow(item: $item)   // ShoppingListView.swift のものを使用
                }
                .onDelete { node.items.remove(atOffsets: $0) }
            } header: {
                Text("買うもの")
            } footer: {
                if !route.canAddFolder {
                    Text("フォルダは\(FolderLimit.maxDepth)階層までです。")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(node.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { addMenu }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .folder: FolderAddView(parent: node, level: route.level)
            case .item:   ItemInfoView(currentFolder: node)
            }
        }
    }
    
    /// 最大階層より下には「フォルダを追加」を出さない
    @ViewBuilder
    private var addMenu: some View {
        if route.canAddFolder {
            Menu {
                Button("フォルダを追加", systemImage: "folder.badge.plus") { activeSheet = .folder }
                Button("アイテムを追加", systemImage: "plus") { activeSheet = .item }
                // 最大階層の「＋」ボタンは activeSheet = .item
            } label: {
                Image(systemName: "plus")
            }
        } else {
            Button {
                activeSheet = .item
            } label: {
                Image(systemName: "plus")
            }
        }
    }
    
    private func addFolder() {
        let name = newName.trimmingCharacters(in: .whitespaces)
        newName = ""
        guard !name.isEmpty, route.canAddFolder else { return }
        let tint = FolderTint.palette[node.children.count % FolderTint.palette.count]
        node.children.append(FolderNode(name: name, tint: tint))
    }
    
    private func addItem() {
        let name = newName.trimmingCharacters(in: .whitespaces)
        newName = ""
        guard !name.isEmpty else { return }
        node.items.append(ShoppingItem(name: name, quantity: "1"))
    }
}

// MARK: - Preview

#Preview {
    HomeView()
        .tint(Color(red: 0.18, green: 0.55, blue: 0.37))
}
