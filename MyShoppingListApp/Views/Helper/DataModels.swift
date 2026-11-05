
import SwiftUI
import SwiftData

// MARK: - 他のモデルと関連しない enum
// 関連するモデルがない enum は、ここ（ファイルの一番上）に置く。今は該当なし。

// MARK: - FolderNode

/// フォルダの階層制限
enum FolderLimit {
    static let maxDepth = 3
    /// アイテムを入れられる最小の階層（1階層目にはアイテムを入れない）
    static let itemMinLevel = 1
}

/// フォルダに使えるアイコンの一覧。
/// アイコンを増やすときは、Assets に画像を追加して、ここに case を1行足すだけ。
/// case の名前は、Assets の画像名と同じにする（rawValue が画像名になる）。
enum CustomIconFolder: String, CaseIterable, Identifiable {
    case apple
    case bike2
    case bike3
    case bike4
    case bike5
    case bike6
    case bike7
    case bike8
    case bike11
    case bike12
    case book1
    case boy1
    case boy2
    case building1
    case building2
    case calendar
    case clock1
    case convenience1
    case cup1
    case fire1
    case girl1
    case girl2
    case grandma1
    case grandpa1
    case heart1
    case home1
    case home2
    case home3
    case home4
    case koban1
    case man1
    case market1
    case market2
    case pencil1
    case post1
    case school1
    case seedling
    case star1
    case woman
    case orange
    case strawberry
    case kiwi
    case banana
    case book2
    case book3
    case book4
    case book5
    case book6
    case book7
    case book8
    case book9
    case book10
    case book11
    case book12
    case book13
    case eraser01
    case file01
    case note01
    case pencilCase01
    case fish01
    case meat01
    case rice01
    case tomato01
    case bread01
    case cabbage01
    case carrot01
    case eggplant01
    case clothes01
    case clothes02
    case clothes03
    case clothes04
    case clothes05
    case clothes06
    case clothes07
    case clothes08
    case clothes09
    case clothes10
    case vehicle1
    case vehicle2
    case vehicle3
    case vehicle4
    case vehicle5
    case vehicle6
    case vehicle7
    case vehicle8
    case animal1
    case animal2
    case animal3
    case animal4
    case animal5
    case animal6
    case animal7
    case animal8
    case animal9
    case animal10
    case animal11
    case animal12
    case animal13
    case animal14
    case camera1
    case music1
    case plane1
    case present1

    var id: String { rawValue }
    
    /// 表示用の Image
    var image: Image { Image(rawValue) }
}

/// フォルダ。子フォルダと、そのフォルダ直下の買うものアイテムを持つ
@Model
final class FolderNode {
    var id: UUID
    var name: String
    /// FolderTint.palette の番号
    var tintIndex: Int
    /// Assets の画像名（CustomIconFolder の rawValue）。nil なら頭文字タイル
    /// 画像を削除・改名しても読み込みエラーにならないよう、enum ではなく文字列で保存する
    var customIconName: String?
    /// 同じ階層での並び順（小さいほど上）
    var sortOrder: Int
    
    var parent: FolderNode?
    
    /// 削除すると、配下のフォルダとアイテムもすべて削除される
    @Relationship(deleteRule: .cascade, inverse: \FolderNode.parent)
    var children: [FolderNode] = []
    
    @Relationship(deleteRule: .cascade, inverse: \ShoppingItem.folder)
    var items: [ShoppingItem] = []
    
    init(name: String,
         tintIndex: Int = 0,
         customIcon: CustomIconFolder? = nil,
         sortOrder: Int = 0) {
        self.id = UUID()
        self.name = name
        self.tintIndex = tintIndex
        self.customIconName = customIcon?.rawValue
        self.sortOrder = sortOrder
    }
    
    // MARK: 表示用
    
    var tint: FolderTint {
        FolderTint.palette[tintIndex % FolderTint.palette.count]
    }
    
    var customIcon: CustomIconFolder? {
        get { customIconName.flatMap { CustomIconFolder(rawValue: $0) } }
        set { customIconName = newValue?.rawValue }
    }
    
    /// 並び順どおりの子フォルダ（SwiftData の配列は順番が保証されないため）
    var sortedChildren: [FolderNode] {
        children.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    /// 並び順どおりのアイテム
    var sortedItems: [ShoppingItem] {
        items.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    /// 子フォルダ内も含めたアイテム数
    var totalItemCount: Int {
        items.count + children.reduce(0) { $0 + $1.totalItemCount }
    }
    
    /// Imageの代わりに表示する頭文字
    var initial: String { String(name.prefix(1)) }
    
    // MARK: 操作
    
    /// このフォルダの直下にアイテムを追加する（一番下に並ぶ）
    @discardableResult
    func addItem(name: String, isPriority: Bool = false, in context: ModelContext) -> ShoppingItem {
        let order = (items.map(\.sortOrder).max() ?? -1) + 1
        let item = ShoppingItem(name: name, isPriority: isPriority, sortOrder: order)
        context.insert(item)
        item.folder = self
        return item
    }
}

extension FolderNode {
    /// 最上位のフォルダ（親がないフォルダ）を並び順で取得する。@Query(FolderNode.rootsDescriptor) で使う
    static var rootsDescriptor: FetchDescriptor<FolderNode> {
        FetchDescriptor<FolderNode>(
            predicate: #Predicate<FolderNode> { $0.parent == nil },
            sortBy: [SortDescriptor(\.sortOrder)]
        )
    }
}

// MARK: - ShoppingItem

/// 買うものアイテム
@Model
final class ShoppingItem {
    var id: UUID
    var name: String
    var isPriority: Bool
    var isDone: Bool
    /// チェックを入れた日（外したら nil）
    var purchasedAt: Date?
    /// 同じフォルダ内での並び順（小さいほど上）
    var sortOrder: Int
    
    var folder: FolderNode?
    
    init(name: String,
         isPriority: Bool = false,
         isDone: Bool = false,
         sortOrder: Int = 0) {
        self.id = UUID()
        self.name = name
        self.isPriority = isPriority
        self.isDone = isDone
        self.purchasedAt = isDone ? Date() : nil
        self.sortOrder = sortOrder
    }
    
    /// チェックを入れた日を記録し、外したら消す
    /// （@Model のプロパティには didSet が使えないため、メソッドにしている）
    func setDone(_ done: Bool) {
        isDone = done
        purchasedAt = done ? Date() : nil
    }
    
    func toggleDone() {
        setDone(!isDone)
    }
}

// MARK: - PurchaseRecord

/// 購入履歴
@Model
final class PurchaseRecord {
    var id: UUID
    var name: String
    /// 表示用のコピー（フォルダを削除・改名しても履歴は変わらない）
    var folderName: String
    var purchasedAt: Date
    /// 将来「元に戻す」で戻す先のフォルダ。関連づけはせず、id だけを覚える
    var folderID: UUID?
    var isPriority: Bool
    
    init(name: String,
         folderName: String,
         purchasedAt: Date,
         folderID: UUID? = nil,
         isPriority: Bool = false) {
        self.id = UUID()
        self.name = name
        self.folderName = folderName
        self.purchasedAt = purchasedAt
        self.folderID = folderID
        self.isPriority = isPriority
    }
}
