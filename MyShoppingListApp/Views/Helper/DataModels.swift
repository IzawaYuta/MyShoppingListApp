
import SwiftUI
import SwiftData

// MARK: - 他のモデルと関連しない enum
// 関連するモデルがない enum は、ここ（ファイルの一番上）に置く。今は該当なし。

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
    case book6
    case book7
    case book8
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
    case bousi01
    case cake01
    case flawer01
    case foto01
    case gear01
    case hanga01
    case happa01
    case kato01
    case kanmuri01
    case konpasu01
    case krakka01
    case kutu01
    case kutusita01
    case mail01
    case megane01
    case mike01
    case movie01
    case nikukyu01
    case pepar01
    case peparminus01
    case peparplus01
    case pin01
    case ribon01
    case tizu01
    case torofie01
    case trash01
    case tree01
    case unbrera01
    case kamihikouki01

    var id: String { rawValue }
    
    /// 表示用の Image
    var image: Image { Image(rawValue) }
}

/// 頻度の種類
/// rawValue は保存用の固定の名前。画面に出す文言は title で持つ
enum RecurrenceFrequency: String, CaseIterable, Identifiable, Codable {
    case daily
    case weekly
    case biweekly
    case monthly
    case yearly
    
    var id: String { rawValue }
    
    /// 画面に表示する名前
    var title: String {
        switch self {
        case .daily:    return "毎日"
        case .weekly:   return "毎週"
        case .biweekly: return "隔週"
        case .monthly:  return "毎月"
        case .yearly:   return "毎年"
        }
    }
    
    /// 次の日付を求めるための Calendar 単位と間隔
    var step: (component: Calendar.Component, value: Int) {
        switch self {
        case .daily:    return (.day, 1)
        case .weekly:   return (.weekOfYear, 1)
        case .biweekly: return (.weekOfYear, 2)
        case .monthly:  return (.month, 1)
        case .yearly:   return (.year, 1)
        }
    }
}
