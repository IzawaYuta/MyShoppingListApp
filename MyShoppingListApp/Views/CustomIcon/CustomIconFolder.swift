
import SwiftUI

/// フォルダに使えるアイコンの一覧。
/// アイコンを増やすときは、Assets に画像を追加して、ここに case を1行足すだけ。
/// case の名前は、Assets の画像名と同じにする（rawValue が画像名になる）。

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
            return [.rice01, .bread01, .meat01, .fish01, .tomato01,.cabbage01,.carrot01,.eggplant01
                    
            ]
        case .fruit:
            return [.apple, .orange, .strawberry, .kiwi, .banana]
            
        case .clothes:
            return [.clothes01, .clothes02, .clothes03, .clothes04, .clothes05, .clothes06, .clothes07, .clothes08, .clothes09, .clothes10
                ]
            
        case .vehicle:
            return [
                .bike2, .bike3, .bike4, .bike5, .bike6,
                .bike7, .bike8, .bike11, .bike12, .vehicle1, .vehicle2, .vehicle3, .vehicle4, .vehicle5, .vehicle6, .vehicle7, .vehicle8
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
