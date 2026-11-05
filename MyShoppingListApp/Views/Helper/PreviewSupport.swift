
import SwiftUI
import SwiftData

/// プレビュー専用のダミーデータ。アプリ本体では使わない（本体は空の状態から始まる）
@MainActor
enum PreviewData {
    /// メモリ上だけのコンテナを作る。withSamples を false にすると空の状態になる
    static func container(withSamples: Bool = true) -> ModelContainer {
        let container = try! ModelContainer(
            for: FolderNode.self, ShoppingItem.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        if withSamples {
            insertSamples(into: container.mainContext)
        }
        return container
    }
    
    private static func insertSamples(into context: ModelContext) {
        /// フォルダを作って、アイテム（名前, 完了済みか）を入れる
        @discardableResult
        func make(_ name: String,
                  tint: Int,
                  icon: CustomIconFolder? = nil,
                  order: Int,
                  parent: FolderNode? = nil,
                  items: [(String, Bool)] = []) -> FolderNode {
            let node = FolderNode(name: name, tintIndex: tint, customIcon: icon, sortOrder: order)
            context.insert(node)
            node.parent = parent
            for (index, entry) in items.enumerated() {
                let item = ShoppingItem(name: entry.0, isDone: entry.1, sortOrder: index)
                context.insert(item)
                item.folder = node
            }
            return node
        }
        
        let food = make("食品", tint: 0, icon: .apple, order: 0)
        let vegetables = make("野菜・果物", tint: 0, order: 0, parent: food,
                              items: [("ミニトマト", false)])
        make("葉物野菜", tint: 0, order: 0, parent: vegetables,
             items: [("ほうれん草", true), ("キャベツ", false)])
        make("根菜", tint: 2, order: 1, parent: vegetables,
             items: [("にんじん", false)])
        make("果物", tint: 3, order: 2, parent: vegetables,
             items: [("バナナ", false)])
        make("肉・魚", tint: 3, order: 1, parent: food,
             items: [("鶏むね肉", false)])
        make("乳製品・卵", tint: 4, order: 2, parent: food,
             items: [("牛乳", false), ("卵", true)])
        
        let daily = make("日用品", tint: 1, order: 1)
        make("洗剤・掃除", tint: 1, order: 0, parent: daily, items: [("洗剤", false)])
        make("紙類", tint: 1, order: 1, parent: daily)
        
        let drinks = make("飲み物", tint: 2, order: 2)
        make("水・お茶", tint: 2, order: 0, parent: drinks)
        
        let seasoning = make("調味料", tint: 3, order: 3)
        make("基本調味料", tint: 3, order: 0, parent: seasoning)
    }
}
