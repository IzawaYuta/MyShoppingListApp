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
    @Persisted var regularName: String = ""
    
    convenience init(regularName: String) {
        self.init()
        self.regularName = regularName
    }
}

// MARK: RegularCategoryListView
struct RegularCategoryListView: View {
    @ObservedResults(CategoryListModel.self) var categoryListModel
    var body: some View {
        NavigationStack {
            List(categoryListModel) { list in
                NavigationLink(destination: RegularItemView(regularItems: list, regularItemId: list.id)) {
                    Text(list.name)
                }
            }
            .navigationTitle("定期リスト")
        }
    }
}

// MARK: RegularItemView
struct RegularItemView: View {
    
    @State private var isRegularItemAdditionAlert = false
    @State private var newRegularItemTextField = ""
    @ObservedResults(RegularItemViewModel.self) var regularItemViewModel
    @State var regularItems: CategoryListModel?
    
    //    @State var item: RegularItemViewModel?
    
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
                .alert("定期品の追加", isPresented: $isRegularItemAdditionAlert) {
                    TextField("定期品", text: $newRegularItemTextField)
                    Button("追加") {
                        addRegularItem()
                        print("\(regularItemViewModel)")
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
        let realm = try! Realm()
        let addRegularItem = RegularItemViewModel(regularName: newRegularItemTextField)
        try! realm.write {
            // 新しい定期品を regularItems に追加
            regularItems?.regularItems.append(addRegularItem)
        }
        newRegularItemTextField = ""
    }
    
    private func loadRegularItem() {
        // Realmから CategoryListModel を取得
        let realm = try! Realm()
        if let category = realm.object(ofType: CategoryListModel.self, forPrimaryKey: regularItemId) {
            self.regularItems = category
            // RealmSwift.List を Array に変換
//            self.regularItemViewModel = Array(category.regularItems)  // RealmSwift.List を配列に変換
        }
    }
}

#Preview {
    RegularCategoryListView()
}
