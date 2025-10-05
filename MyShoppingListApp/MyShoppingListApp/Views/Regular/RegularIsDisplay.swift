//
//  RegularIsDisplay.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/10/05.
//

import SwiftUI
import RealmSwift

struct RegularIsDisplay: View {
    
    @ObservedResults(CategoryListModel.self, sortDescriptor: SortDescriptor(keyPath: "sortIndex", ascending: true))
    var categoryListModel
    
    @State private var select = Set<String>()
    
    var body: some View {
        if categoryListModel.isEmpty {
            Text("カテゴリーを追加しましょう")
        } else {
            ZStack(alignment: .bottom) {
                List(categoryListModel, id: \.id) { list in
                    HStack {
                        Image(systemName: select.contains(list.id) ? "circle.fill" : "circle")
                        Text(list.name)
                        Spacer()
                        if list.favorite {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        toggleSelection(for: list.id)
                    }
                }
                .onAppear {
                    let initialSelected = categoryListModel.filter { $0.isDisplay }.map { $0.id }
                    select = Set(initialSelected)
                }
                Button(action: {
                    save()
                }) {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    private func toggleSelection(for id: String) {
        if select.contains(id) {
            select.remove(id)
        } else {
            select.insert(id)
        }
    }
    
    private func save() {
        let realm = try! Realm()
        
        try! realm.write {
            for frozenCategory in categoryListModel {
                if let category = frozenCategory.thaw() {
                    category.isDisplay = select.contains(category.id)
                }
            }
        }
    }
}

#Preview {
    RegularIsDisplay()
}
