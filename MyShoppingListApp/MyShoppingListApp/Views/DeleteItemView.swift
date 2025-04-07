//
//  DeleteItemView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/04/01.
//

import SwiftUI
import RealmSwift

class DeleteItemViewModel: Object, Identifiable {
    @Persisted var id = UUID()
    @Persisted var name = ""
}

struct DeleteItemView: View {
    @ObservedResults(DeleteItemViewModel.self) var deleteItemViewModel
    
    var body: some View {
        List {
            ForEach(deleteItemViewModel) { list in
                Text(list.name)
            }
        }
    }
}

#Preview {
    DeleteItemView()
}
