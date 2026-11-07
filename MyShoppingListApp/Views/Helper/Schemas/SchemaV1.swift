
import SwiftData
import Foundation

// MARK: - Schema V1（公開する最初の形）

enum SchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [FolderNode.self, ShoppingItem.self, PurchaseRecord.self, RecurringItem.self, FrequentItem.self]
    }
    
    // MARK: - FolderNode
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
        /// お気に入りか（1階層目のフォルダだけで使う）
        var isFavorite: Bool = false
        
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
        func addItem(name: String,
                     isPriority: Bool = false,
                     isAutoAdded: Bool = false,
                     in context: ModelContext) -> ShoppingItem {
            let order = (items.map(\.sortOrder).max() ?? -1) + 1
            let item = ShoppingItem(name: name, isPriority: isPriority, sortOrder: order)
            item.isAutoAdded = isAutoAdded
            context.insert(item)
            item.folder = self
            return item
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
        
        /// 定期アイテムの自動追加で入ったものか
        var isAutoAdded: Bool = false
        
        /// 数量
        var quantity: String = ""
        
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

    // MARK: - RecurringItem
    /// 定期アイテム
    @Model
    final class RecurringItem {
        var id: UUID = UUID()
        var name: String = ""
        var quantity: String = ""
        /// 追加先のフォルダ。関連づけはせず、id だけを覚える
        var folderIDs: [UUID] = []
        var startDate: Date = Date()
        var frequency: RecurrenceFrequency = RecurrenceFrequency.weekly
        var hasEndDate: Bool = false
        var endDate: Date = Date()
        var isPriority: Bool = false
        var notifiesOnAdd: Bool = true
        var isActive: Bool = true
        /// 一覧の並び順（作成した順）
        var createdAt: Date = Date()
        /// 最後に自動追加した回の日付（同じ回を二重に追加しないための記録）
        var lastAddedDate: Date? = nil
        
        init(draft: RecurringItemDraft) {
            apply(draft)
        }
        
        /// 入力画面の内容をこのアイテムに反映する（RecurringItemDraft は RegularItemInfoView.swift のもの）
        func apply(_ draft: RecurringItemDraft) {
            name = draft.name
            quantity = draft.quantity
            folderIDs = Array(draft.folderIDs)
            startDate = draft.startDate
            frequency = draft.frequency
            hasEndDate = draft.hasEndDate
            endDate = draft.endDate
            isPriority = draft.isPriority
            notifiesOnAdd = draft.notifiesOnAdd
            isActive = draft.isActive
        }
        
        /// 入力画面に渡す、今の内容
        var draft: RecurringItemDraft {
            var draft = RecurringItemDraft()
            draft.name = name
            draft.quantity = quantity
            draft.folderIDs = Set(folderIDs)
            draft.startDate = startDate
            draft.frequency = frequency
            draft.hasEndDate = hasEndDate
            draft.endDate = endDate
            draft.isPriority = isPriority
            draft.notifiesOnAdd = notifiesOnAdd
            draft.isActive = isActive
            return draft
        }
        
        /// 名前の下に表示する頻度（例：毎週 / 隔週 / 毎月1日）
        var subtitle: String {
            let calendar = Calendar.current
            let day = calendar.component(.day, from: startDate)
            let month = calendar.component(.month, from: startDate)
            switch frequency {
            case .monthly: return "毎月\(day)日"
            case .yearly:  return "毎年\(month)月\(day)日"
            default:       return frequency.title
            }
        }
        
        /// 終了日を過ぎているか（終了日の翌日以降）
        var isEnded: Bool {
            guard hasEndDate else { return false }
            let calendar = Calendar.current
            return calendar.startOfDay(for: .now) > calendar.startOfDay(for: endDate)
        }
    }

    // MARK: - FrequentItem
    /// よく買うもの（登録しておいて、あとで選んでリストに追加する）
    @Model
    final class FrequentItem {
        var id: UUID = UUID()
        var name: String = ""
        var isPriority: Bool = false
        /// 数量（将来の機能。今は画面から入力しない）
        var quantity: String = ""
        /// 追加先のフォルダ（アイテムを入れられる2階層目以降のフォルダの id）
        /// 関連づけはせず、id だけを覚える
        var folderIDs: [UUID] = []
        /// 一覧の並び順（登録した順）
        var createdAt: Date = Date()
        
        init(name: String, isPriority: Bool = false, folderIDs: [UUID] = []) {
            self.name = name
            self.isPriority = isPriority
            self.folderIDs = folderIDs
        }
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


// 今までの名前で使えるようにする（画面のコードは直さない）
typealias FolderNode = SchemaV1.FolderNode
typealias ShoppingItem = SchemaV1.ShoppingItem
typealias PurchaseRecord = SchemaV1.PurchaseRecord
typealias RecurringItem = SchemaV1.RecurringItem
typealias FrequentItem = SchemaV1.FrequentItem
