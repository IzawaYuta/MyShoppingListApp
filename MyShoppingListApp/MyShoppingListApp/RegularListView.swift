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
    
    @State private var isRegularItemAdditionAlert = false
    @State private var newRegularItemTextField = ""
    @State private var regularItemViewModel: [RegularItemViewModel] = []
    
    @State var item: RegularItemViewModel?
    
    var regularItemId: String
    
    var body: some View {
        NavigationStack {
            List(regularItemViewModel) { list in
                Text(list.regularName)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    isRegularItemAdditionAlert.toggle()
                }) {
                    Image(systemName: "plus")
                }
                .alert("定期カテゴリー追加", isPresented: $isRegularItemAdditionAlert) {
                    TextField("定期品", text: $newRegularItemTextField)
                    Button("追加") {
                        addRegularItem()
                    }
                    Button("キャンセル", role: .cancel) {
                    }
                }
            }
        }
        .onAppear {
            loadRegularItem()
        }
    }
    
    private func addRegularItem() {
        guard !newRegularItemTextField.isEmpty else {
            return
        }
        let realm = try!Realm()
        let addRegularItem = RegularItemViewModel()
        try! realm.write {
            regularItemViewModel.append(addRegularItem)
        }
        newRegularItemTextField = ""
    }
    
    private func loadRegularItem() {
        // Realmからデータを取得
        let realm = try! Realm()
        if let regularItem = realm.object(ofType: RegularItemViewModel.self, forPrimaryKey: regularItemId) {
            self.item = regularItem
        }
    }
}

#Preview {
    RegularCategoryListView()
}
