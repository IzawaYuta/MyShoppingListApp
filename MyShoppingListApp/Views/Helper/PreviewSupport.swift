
import SwiftUI
import SwiftData

/// プレビュー専用のダミーデータ。アプリ本体では使わない（本体は空の状態から始まる）
@MainActor
enum PreviewData {
    /// メモリ上だけのコンテナを作る。withSamples を false にすると空の状態になる
    static func container(withSamples: Bool = true) -> ModelContainer {
        let container = try! ModelContainer(
            for: FolderNode.self, ShoppingItem.self, PurchaseRecord.self, RecurringItem.self, FrequentItem.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        if withSamples {
            insertSamples(into: container.mainContext)
            insertPurchaseSamples(into: container.mainContext)
            insertRecurringSamples(into: container.mainContext)
            insertFrequentSamples(into: container.mainContext)
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
    
    /// 購入履歴のダミーデータ
    private static func insertPurchaseSamples(into context: ModelContext) {
        let cal = Calendar.current
        let now = Date()
        
        func day(_ offset: Int, hour: Int) -> Date {
            let base = cal.date(byAdding: .day, value: -offset, to: now) ?? now
            return cal.date(bySettingHour: hour, minute: 0, second: 0, of: base) ?? base
        }
        
        let records: [(name: String, folder: String, date: Date)] = [
            ("牛乳", "乳製品", day(0, hour: 18)),
            ("卵", "卵・納豆", day(0, hour: 17)),
            ("キャベツ", "野菜", day(0, hour: 16)),
            
            ("食器用洗剤", "キッチン用品", day(1, hour: 19)),
            ("ティッシュ", "日用品", day(1, hour: 18)),
            
            ("鶏むね肉", "肉・魚", day(3, hour: 18)),
            ("食パン", "パン", day(3, hour: 17)),
            ("ヨーグルト", "乳製品", day(3, hour: 16)),
            
            ("トイレットペーパー", "日用品", day(6, hour: 14)),
            ("コーヒー豆", "飲み物", day(6, hour: 13))
        ]
        
        for record in records {
            context.insert(PurchaseRecord(
                name: record.name,
                folderName: record.folder,
                purchasedAt: record.date
            ))
        }
    }
    
    /// 定期アイテムのダミーデータ
    private static func insertRecurringSamples(into context: ModelContext) {
        func make(_ name: String,
                  _ frequency: RecurrenceFrequency,
                  day: Int = 1,
                  priority: Bool = false,
                  active: Bool = true) {
            var draft = RecurringItemDraft()
            draft.name = name
            draft.frequency = frequency
            draft.startDate = Calendar.current.date(from: DateComponents(year: 2026, month: 11, day: day)) ?? .now
            draft.isPriority = priority
            draft.isActive = active
            context.insert(RecurringItem(draft: draft))
        }
        
        make("牛乳", .weekly, priority: true)
        make("卵", .weekly)
        make("トイレットペーパー", .monthly, day: 1)
        make("ヨーグルト", .biweekly)
        make("洗剤", .monthly, day: 15)
        make("ミネラルウォーター", .weekly, active: false)
    }
    
    /// よく買うもののダミーデータ。追加先は、フォルダ名から id を探して決める
    private static func insertFrequentSamples(into context: ModelContext) {
        // 先に作ったフォルダを、検索で見つけられるように保存しておく
        try? context.save()
        let folders = (try? context.fetch(FetchDescriptor<FolderNode>())) ?? []
        let now = Date()
        var order = 0
        
        func make(_ name: String, in folderName: String, priority: Bool = false) {
            let folderID = folders.first { $0.name == folderName }?.id
            let item = FrequentItem(
                name: name,
                isPriority: priority,
                folderIDs: folderID.map { [$0] } ?? []
            )
            // 登録した順に並ぶよう、1秒ずつずらす
            item.createdAt = now.addingTimeInterval(Double(order))
            order += 1
            context.insert(item)
        }
        
        make("牛乳", in: "乳製品・卵", priority: true)
        make("卵", in: "乳製品・卵")
        make("キャベツ", in: "野菜・果物")
        make("鶏むね肉", in: "肉・魚")
        make("洗剤", in: "洗剤・掃除")
        make("トイレットペーパー", in: "紙類")
        make("ミネラルウォーター", in: "水・お茶")
        make("塩", in: "基本調味料")
    }
}
