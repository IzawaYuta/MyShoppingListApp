//
//  CategoryListView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/03/21.
//

import SwiftUI
import RealmSwift
import FirebaseAnalytics
import FirebaseAnalytics

// MARK: CategoryListView
struct CategoryListView: View {
    
    @AppStorage("showFavoritesOnly") private var showFavoritesOnly = false
    
    @State private var isCategoryAdditionAlert = false // カテゴリー追加アラート
    @State private var newCategoryTextField = "" // NEWカテゴリーTextField
    @State private var isModalPresented = false
    @State private var editMode: EditMode = .inactive
    @ObservedResults(CategoryListModel.self, sortDescriptor: SortDescriptor(keyPath: "sortIndex", ascending: true))
    var categoryListModel
    
    var filteredCategories: [CategoryListModel] {
        if showFavoritesOnly {
            return categoryListModel.filter { $0.favorite }
        } else {
            return Array(categoryListModel)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if categoryListModel.isEmpty {
                    Text("カテゴリーを追加しましょう！")
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredCategories) { category in
                            NavigationLink(destination: ItemListView(category: category, categoryId: category.id)) {
                                HStack {
                                    Text(category.name)
                                    if category.isOn {
                                        Image(systemName: "person.2.fill")
                                            .font(.system(size: 15))
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
//                                    Text("\(category.uncheckedItemCount)/\(category.itemCount)")
//                                        .foregroundColor(.gray)
                                    if (category.favorite) {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                    }
                                } ///HStack
                                .frame(height: 10)
                                .swipeActions {
                                    Button(action: {
                                        changeFavorite(category)
                                    }) {
                                        Image(systemName: "star.fill")
                                    }
                                    .tint(category.favorite ? .yellow : .gray)
                                }
                            }
                        }
                        .onMove(perform: moveCategory)
                        .onDelete(perform: deleteCategory)
                    } // List
                    .environment(\.editMode, $editMode)
                }
            }
            .onAppear {
                Analytics.logEvent(AnalyticsEventScreenView, parameters: [
                    AnalyticsParameterScreenName: "CategoryListView",
                    AnalyticsParameterScreenClass: "CategoryListView"
                ])
            }
            .navigationTitle(showFavoritesOnly ? "カテゴリー(★)" : "カテゴリー")
            .toolbarTitleDisplayMode(.automatic)
            .toolbar(.visible, for:.tabBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button(action: {
                            isCategoryAdditionAlert.toggle()
                        }) {
                            Image(systemName: "plus")
                        }
                        .fullScreenCover(isPresented: $isCategoryAdditionAlert) {
                            CustomAlertView(
                                newText: $newCategoryTextField,
                                onAdd: {
                                    addCategory()
                                    isCategoryAdditionAlert = false
                                },
                                onCancel: {
                                    isCategoryAdditionAlert = false
                                    newCategoryTextField = ""
                                }
                                
                            )
                            .offset(y: 120)
                            .presentationBackground(Color.clear)
                        }
                        Menu {
                            Button("お問い合わせ") {
                                if let url = URL(string: "https://www.notion.so/21d95f7f1d1080949bf3e3603829544c?source=copy_link") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            Link("プライバシーポリシー", destination: URL(string: "https://ten-emery-9f5.notion.site/1dc95f7f1d1080ceb0eae74b2ada2c5a")!)
                            Link("アプリを共有", destination: URL(string: "https://apps.apple.com/jp/app/%E3%82%AB%E3%82%B4%E3%82%8A%E3%81%99%E3%81%A8/id6745005617?itscg=30200&itsct=apps_box_link&mttnsubad=6745005617")!)
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button(action: {
                            showFavoritesOnly.toggle()
                        }) {
                            Text("お気に入り")
                            Image(systemName: "star.fill")
                        }
                        Button(action: {
                            if editMode.isEditing {
                                editMode = .inactive
                            } else {
                                editMode = .active
                            }
                        }) {
                            Text(editMode.isEditing ? "完了" : "編集")
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
        } /// NavigationView
    }
    
    
    private func addCategory() {
        guard !newCategoryTextField.isEmpty else {
            return
        }
        let realm = try!Realm()
        let newCategory = CategoryListModel(name: newCategoryTextField, items: [], regularItems: [])
        try! realm.write {
            $categoryListModel.append(newCategory)
        }
        newCategoryTextField = ""
    }
    
    private func deleteCategory(at offsets: IndexSet) {
        let realm = try! Realm()
        try! realm.write {
            $categoryListModel.remove(atOffsets: offsets)
        }
    }
    
    private func moveCategory(from source: IndexSet, to destination: Int) {
        let realm = try! Realm()
        
        // thaw() を使ってフローズン状態を解除
        guard let thawedCategories = categoryListModel.thaw() else {
            print("Failed to thaw categories")
            return
        }
        
        // 並び替え用の一時配列を作成
        var reorderedCategories = Array(thawedCategories)
        reorderedCategories.move(fromOffsets: source, toOffset: destination)
        
        // Realm に書き込み
        try! realm.write {
            for (index, category) in reorderedCategories.enumerated() {
                category.sortIndex = index
            }
        }
    }
    
    private func changeFavorite(_ category: CategoryListModel) {
        let realm = try! Realm()
        if let thawed = category.thaw() {
            try! realm.write {
                thawed.favorite.toggle()
            }
        }
    }
}

// MARK: ItemListView
struct ItemListView: View {
    
    @State private var isShoppingListAdditionAlert = false
    @State private var newShoppingListTextField = ""
    @State private var isTrash = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedRealmObject var category: CategoryListModel
    
    var categoryId: String
    
    var body: some View {
        VStack {
            List {
                VStack {
                    HStack {
                        TextField("アイテム", text: $newShoppingListTextField)
                        Button(action: {
                            addShoppingList()
                            buttonAnalytics()
                        }) {
                            if colorScheme == .dark {
                                Text("追加")
                                    .padding()
                                    .foregroundColor(newShoppingListTextField.isEmpty ? Color.white : Color.blue.opacity(0.5))
                                    .cornerRadius(8)
                            } else {
                                Text("追加")
                                    .padding()
                                    .foregroundColor(newShoppingListTextField.isEmpty ? Color.gray : Color.blue)
                                    .cornerRadius(8)
                            }
                        }
                        .disabled(newShoppingListTextField.isEmpty)
                    }
                    .padding(.horizontal)
                    .background(.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .cornerRadius(8)
                    Spacer()
                    ForEach(category.items) { item in
                        HStack {
                            Image(systemName: item.isChecked ? "checkmark.square" : "square")
                                .foregroundStyle(item.isChecked ? .green : .red)
                                .scaleEffect(item.isChecked ? 1.0 : 1.5)
                                .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.2), value: item.isChecked)
                            Spacer()
                                .frame(width: 15)
                            Text(item.name)
                                .font(.system(size: item.isChecked ? 17 : 20))
                                .foregroundStyle(item.isChecked ? Color.gray : Color.primary)
                                .strikethrough(item.isChecked, color: .gray)
                                .animation(.easeOut, value: item.isChecked)
                            
                            Spacer()
                        }
                        .frame(height: item.isChecked ? 5 : 20)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                toggleCheckState(for: item)
                            }
                        }
                    }
                    .frame(height: 40)
                }
                .listRowBackground(Color.clear)
            }
            .environment(\.defaultMinListRowHeight, 3)
        }
        .onAppear {
            Analytics.logEvent(AnalyticsEventScreenView, parameters: [
                AnalyticsParameterScreenName: "ItemListView",
                AnalyticsParameterScreenClass: "ItemListView"
            ])
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    deleteCheckedItems()
                    isTrash = true
                }) {
                    Image(systemName: "trash")
                }
                .disabled(category.items.filter{ $0.isChecked}.isEmpty)
                .sheet(isPresented: $isTrash) {
                    TrashSuccessAlertView()
                        .presentationDetents([.fraction(0.3)])
                        .presentationBackground(.clear)
                        .transition(.move(edge: .bottom))
                }
                .onChange(of: isTrash) { newValue in
                    if newValue {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                isTrash = false
                            }
                        }
                    }
                }
            }
            ToolbarItem(placement: .principal) {
                HStack {
                    Text(category.name)
                    if category.isOn {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 10))
                    }
                }
            }
        } // toolbar
    }
    
    private func addShoppingList() {
        let realm = try! Realm()
        guard !newShoppingListTextField.isEmpty else { return }
        let newItem = Item(name: newShoppingListTextField)
        try! realm.write {
            $category.items.append(newItem)
        }
        newShoppingListTextField = ""
    }
    
    private func toggleCheckState(for item: Item) {
        let realm = try! Realm()
        // itemをthawして変更できるようにする
        if let thawedItem = item.thaw() {
            try! realm.write {
                thawedItem.isChecked.toggle()
            }
        }
    }
    private func deleteCheckedItems() {
        let realm = try! Realm()
        
        // category.itemsをthawして変更できるようにする
        if let thawedCategory = category.thaw() {
            let checkedItems = thawedCategory.items.filter { $0.isChecked }
            
            try! realm.write {
                for item in checkedItems {
                    let deleteItem = DeleteItemViewModel()
                    deleteItem.id = item.id.uuidString
                    deleteItem.name = item.name
                    deleteItem.date = Date()
                    realm.add(deleteItem)
                    realm.delete(item)
                    print("\(DeleteItemViewModel())")
                }
            }
        }
    }
    
    private func buttonAnalytics() {
        Analytics.logEvent("button_tapped", parameters: [
            "item_addButton": "item_addButton"
        ])
    }
}


#Preview {
    CategoryListView()
}
