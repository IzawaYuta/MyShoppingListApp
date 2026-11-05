
import SwiftUI
import SwiftData

// MARK: - Sheet

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

// MARK: - Tint

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

// MARK: - Route

/// 画面遷移用。level はそのフォルダの階層（1〜maxDepth）
struct FolderRoute: Hashable {
    let node: FolderNode
    let level: Int
    
    /// このフォルダの中に、さらにフォルダを作成できるか
    var canAddFolder: Bool { level < FolderLimit.maxDepth }
    var canHoldItems: Bool { level >= FolderLimit.itemMinLevel }
    
    // 保存前後で SwiftData の内部IDが変わることがあるため、自分で持っている id で比べる
    static func == (lhs: FolderRoute, rhs: FolderRoute) -> Bool {
        lhs.node.id == rhs.node.id && lhs.level == rhs.level
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(node.id)
        hasher.combine(level)
    }
}

// MARK: - Image

/// フォルダのアイコンの見た目
struct FolderImageView: View {
    let name: String
    let tint: FolderTint
    let customIcon: CustomIconFolder?
    
    private var initial: String { String(name.prefix(1)) }
    
    var body: some View {
        Group {
            if let customIcon {
                customIcon.image
                    .resizable()
                    .scaledToFit()
                    .background(Color.white)
            } else {
                // imageName がないときは、今までの頭文字タイル
                Text(initial)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(tint.foreground)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(tint.background)
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
            FolderImageView(name: node.name, tint: node.tint, customIcon: node.customIcon)
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
    @Environment(\.modelContext) private var modelContext
    @Query(FolderNode.rootsDescriptor) private var roots: [FolderNode]
    
    @State private var activeSheet: ActiveSheet?
    @State private var editMode: EditMode = .inactive
    @State private var path: [FolderRoute] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section {
                    ForEach(roots) { folder in
                        FolderListRow(node: folder, level: 1) {
                            activeSheet = .editFolder(folder)
                        }
                    }
                    .onDelete { offsets in
                        // 配下のフォルダとアイテムも一緒に削除される（cascade）
                        for index in offsets {
                            modelContext.delete(roots[index])
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .environment(\.editMode, $editMode)
            .navigationTitle("カテゴリー")
            .navigationDestination(for: FolderRoute.self) { route in
                FolderDetailView(route: route, path: $path)
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
    @Binding var path: [FolderRoute]
    @State private var editMode: EditMode = .inactive
    @State private var activeSheet: ActiveSheet?
    @State private var showTrashAlert = false
    
    @Environment(\.modelContext) private var modelContext
    @Environment(PurchaseStore.self) private var purchaseStore
    @Environment(ToastCenter.self) private var toast
    
    init(route: FolderRoute, path: Binding<[FolderRoute]>) {
        self.route = route
        self._path = path
    }
    
    private var node: FolderNode { route.node }
    private var children: [FolderNode] { node.sortedChildren }
    private var items: [ShoppingItem] { node.sortedItems }
    private var completedCount: Int { node.items.filter { $0.isDone }.count }
    
    /// ホームから今いるフォルダまでの道筋
    private var breadcrumb: [FolderRoute] {
        guard let index = path.firstIndex(of: route) else { return [route] }
        return Array(path.prefix(through: index))
    }
    
    var body: some View {
        List {
            // 子フォルダ（最大階層のフォルダには子フォルダがないため表示されない）
            if route.canAddFolder && !children.isEmpty {
                Section {
                    ForEach(children) { child in
                        FolderListRow(node: child, level: route.level + 1) {
                            activeSheet = .editFolder(child)
                        }
                    }
                    .onDelete { offsets in
                        let targets = offsets.map { children[$0] }
                        for target in targets {
                            modelContext.delete(target)
                        }
                    }
                } header: {
                    breadcrumbHeader
                }
            }
            
            Section {
                ForEach(items) { item in
                    ItemRow(item: item)
                }
                .onDelete { offsets in
                    let targets = offsets.map { items[$0] }
                    for target in targets {
                        modelContext.delete(target)
                    }
                }
            } header: {
                if !route.canAddFolder || children.isEmpty {
                    breadcrumbHeader
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
            Button("削除", role: .destructive) {
                archiveCompleted()
                toast.show("削除しました", kind: .success, animation: .blur)
            }
        } message: {
            Text("完了済みの\(completedCount)件を、リストから削除して購入履歴に移します。")
        }
    }
    
    ///現在階層のヘッダー表示判定
    private var breadcrumbHeader: some View {
        BreadcrumbBarView(
            routes: breadcrumb,
            onSelectHome: { path.removeAll() },
            onSelect: { target in
                if let index = path.firstIndex(of: target) {
                    path = Array(path.prefix(through: index))
                }
            }
        )
        .padding(.leading, -20)
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
    
    /// 完了済みのアイテムを購入履歴に移して、リストから削除する
    private func archiveCompleted() {
        let doneItems = node.items.filter { $0.isDone }
        let records = doneItems.map { item in
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
            for item in doneItems {
                modelContext.delete(item)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    HomeView()
        .modelContainer(PreviewData.container())
        .environment(PurchaseStore())
        .toastHost(ToastCenter())
        .tint(Color(red: 0.18, green: 0.55, blue: 0.37))
}
