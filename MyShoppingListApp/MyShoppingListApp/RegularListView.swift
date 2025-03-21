//
//  RegularListView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/03/21.
//

import SwiftUI
import RealmSwift

// MARK: RegularListViewModel
class RegularItemViewModel: Object, Identifiable {
    @Persisted var id = UUID()
    @Persisted var regularName: String
    
    convenience init(regularName: String) {
        self.init()
        self.regularName = regularName
    }
}

struct RegularCategoryListView: View {
    @ObservedResults(CategoryListModel.self) var categoryListModel
    var body: some View {
        List(categoryListModel) { list in
            Text(list.name)
        }
    }
}

// MARK: RegularListView
struct RegularItemView: View {
    
    @State private var regularItemViewModel: [RegularItemViewModel] = [RegularItemViewModel(regularName: "あ")]
    
    var body: some View {
        List(regularItemViewModel) { list in
            Text(list.regularName)
        }
    }
}

#Preview {
    RegularCategoryListView()
}
