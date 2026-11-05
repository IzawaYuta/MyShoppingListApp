
import SwiftUI

// MARK: - Model

/// よく買うもの（登録しておいて、あとで選んでリストに追加する）
struct FrequentItem: Identifiable {
    var id = UUID()
    var name: String
    var isPriority: Bool = false
    /// 追加先のフォルダ（アイテムを入れられる2階層目以降のフォルダの id）
    var folderIDs: Set<UUID> = []
}

// MARK: - Store

/// よく買うものの一覧（複数の画面で共有）
@Observable
final class FrequentItemStore {
    var items: [FrequentItem]
    
    init(items: [FrequentItem] = []) {
        self.items = items
    }
}

// MARK: - Dummy Data

extension FrequentItemStore {
    /// ダミーデータ。フォルダ名から追加先の id を探して作る
    static func sample(folders: [FolderNode]) -> FrequentItemStore {
        func make(_ name: String, in folderName: String, priority: Bool = false) -> FrequentItem {
            let id = folders.first { $0.name == folderName }?.id
            return FrequentItem(name: name, isPriority: priority, folderIDs: id.map { [$0] } ?? [])
        }
        
        return FrequentItemStore(items: [
            make("牛乳", in: "乳製品・卵", priority: true),
            make("卵", in: "乳製品・卵"),
            make("キャベツ", in: "野菜・果物"),
            make("鶏むね肉", in: "肉・魚"),
            make("洗剤", in: "洗剤・掃除"),
            make("トイレットペーパー", in: "紙類"),
            make("ミネラルウォーター", in: "水・お茶"),
            make("塩", in: "基本調味料")
        ])
    }
}
