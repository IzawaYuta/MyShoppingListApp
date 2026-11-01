
import SwiftUI

/// フォルダに使えるアイコンの一覧。
/// アイコンを増やすときは、Assets に画像を追加して、ここに case を1行足すだけ。
/// case の名前は、Assets の画像名と同じにする（rawValue が画像名になる）。
enum CustomIconFolder: String, CaseIterable, Identifiable {
    case apple
    case bike1
    case bike2
    case bike3
    case bike4
    case bike5
    case bike6
    case bike7
    case bike8
    case bike9
    case bike10
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

enum FolderIconCategory: String, CaseIterable, Identifiable {
    case food = "食べ物"
    case fruit = "果物"
    case clothes = "洋服"
    case vehicle = "乗り物"
    case people = "人物"
    case animal = "動物"
    case building = "建物"
    case lifestyle = "暮らし"
    case stationery = "文房具"
    case other = "その他"
    
    var id: String { rawValue }
    
    var icons: [CustomIconFolder] {
        switch self {
        case .food:
            return [.fish01, .meat01, .rice01, .tomato01, .bread01,.cabbage01,.carrot01,.eggplant01
                    
            ]
        case .fruit:
            return [.apple, .orange, .strawberry, .kiwi, .banana]
            
        case .clothes:
            return [.clothes01, .clothes02, .clothes03, .clothes04, .clothes05, .clothes06, .clothes07, .clothes08, .clothes09, .clothes10
                ]
            
        case .vehicle:
            return [
                .bike1, .bike2, .bike3, .bike4, .bike5, .bike6,
                .bike7, .bike8, .bike9, .bike10, .bike11, .bike12, .vehicle1, .vehicle2, .vehicle3, .vehicle4, .vehicle5, .vehicle6, .vehicle7, .vehicle8
            ]
            
        case.animal:
            return [.animal1, .animal2, .animal3, .animal4, .animal5, .animal6, .animal7, .animal8, .animal9, .animal10, .animal11, .animal12, .animal13, .animal14]
            
        case .people:
            return [
                .boy1, .boy2, .girl1, .girl2,
                .grandma1, .grandpa1, .man1, .woman
            ]
            
        case .building:
            return [
                .building1, .building2, .home1, .home2,
                .home3, .home4, .koban1, .school1,
                .convenience1, .market1, .market2, .post1, .fire1
            ]
            
        case .lifestyle:
            return [
                .book1, .book2, .book3, .book4, .book5, .book6, .book7, .book8,
                .book9, .book10, .book11, .book12, .book13
            ]
            
        case .stationery:
            return [.pencil1, .eraser01, .file01, .note01]
        case .other:
            return [.seedling, .star1, .calendar, .clock1, .heart1, .cup1, .camera1, .music1, .plane1, .present1]
        }
    }
}
