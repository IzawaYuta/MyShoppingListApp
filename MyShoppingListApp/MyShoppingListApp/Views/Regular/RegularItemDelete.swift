//
//  RegularItemDelete.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/10/26.
//

import SwiftUI
import RealmSwift

struct RegularItemDelete: View {
    @ObservedRealmObject var categoryListModel: CategoryListModel
    
    var body: some View {
        let regularItemsArray = Array(categoryListModel.regularItems)
            .sorted { $0.furigana < $1.furigana }
        
        List {
            ForEach(regularItemsArray, id: \.id) { item in
                Text(item.name)
            }
            .onDelete { indexSet in
                deleteItem(at: indexSet)
            }
        }
    }
    
    private func deleteItem(at indexSet: IndexSet) {
        guard let thawedCategory = categoryListModel.thaw() else { return } // ← thaw で書き込み可能に
        let itemsToDelete = indexSet.map { Array(thawedCategory.regularItems)[$0] }
        
        guard let realm = thawedCategory.realm else { return }
        try! realm.write {
            realm.delete(itemsToDelete)
        }
    }
}

#Preview {
//    RegularItemDelete()
}
