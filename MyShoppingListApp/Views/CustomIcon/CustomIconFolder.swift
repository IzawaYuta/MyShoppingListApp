
import SwiftUI

/// フォルダに使えるアイコンの一覧。
/// アイコンを増やすときは、Assets に画像を追加して、ここに case を1行足すだけ。
/// case の名前は、Assets の画像名と同じにする（rawValue が画像名になる）。
enum FolderIcon: String, CaseIterable, Identifiable {
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
    case bike13
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
    
    var id: String { rawValue }
    
}
