//
//  Model.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/09/23.
//

import Foundation
import RealmSwift

// MARK: Item
class Item: Object, Identifiable {
    @Persisted var id = UUID()
    @Persisted var name: String = ""
    @Persisted var isChecked: Bool = false
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

// MARK: CategoryListModel
class CategoryListModel: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var name: String = ""
    @Persisted var items = RealmSwift.List<Item>()
    @Persisted var sortIndex: Int // 並び順を保持
    @Persisted var regularItems = RealmSwift.List<RegularItem>() // 定期品リスト
    @Persisted var isOn: Bool = false
    @Persisted var favorite: Bool = false
    @Persisted var isDisplay = false //リストの表示非表示
    
    convenience init(name: String, items: [String], regularItems : [String]) {
        self.init()
        self.name = name
        self.items.append(objectsIn: items.map { Item(name: $0) }) // 変換して追加
        self.items.append(objectsIn: items.map { Item(name: $0) }) // 変換して追加
    }
    
    var itemCount: Int {
        return items.count
    }
    var uncheckedItemCount: Int {
        return items.filter { !$0.isChecked }.count
    }
}

