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
    
//        var regularItemsCount: Int {
//            return regularItems.count
//        }
}


// MARK: CategoryListView
struct CategoryListView: View {
    
    @State private var isCategoryAdditionAlert = false // カテゴリー追加アラート
    @State private var newCategoryTextField = "" // NEWカテゴリーTextField
    @State private var isModalPresented = false
    @State private var editMode: EditMode = .inactive
//    @ObservedResults(CategoryListModel.self) var categoryListModel
    @ObservedResults(CategoryListModel.self, sortDescriptor: SortDescriptor(keyPath: "sortIndex", ascending: true))
    var categoryListModel
    
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
                        ForEach(categoryListModel) { category in
                            NavigationLink(destination: ItemListView(category: category, categoryId: category.id)) {
                                HStack {
                                    Text(category.name)
                                    if category.isOn {
                                        Image(systemName: "person.2.fill")
                                            .font(.system(size: 15))
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Text("\(category.uncheckedItemCount)/\(category.itemCount)")
                                        .foregroundColor(.gray)
                                } ///HStack
                                .frame(height: 10)
                            }
                        }
                        .onMove(perform: moveCategory)
                        .onDelete(perform: deleteCategory)
                    } // List
                    .environment(\.editMode, $editMode)
                    .scrollContentBackground(.hidden)
//                        .background(
//                            LinearGradient(gradient: Gradient(colors: [.cyan.opacity(0.15), .purple.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing)
//                        )
                }
            }
            .background(
                RadialGradient(gradient: Gradient(colors: [.shoppingListBack, .white]), center: .top, startRadius: 300, endRadius: 500)
            )
            .onAppear {
                Analytics.logEvent(AnalyticsEventScreenView, parameters: [
                    AnalyticsParameterScreenName: "CategoryListView",
                    AnalyticsParameterScreenClass: "CategoryListView"
                ])
            }
            .navigationTitle("カテゴリー")
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
                    Button(action: {
                        if editMode.isEditing {
                            editMode = .inactive
                        } else {
                            editMode = .active
                        }
                    }) {
                        Text(editMode.isEditing ? "完了" : "編集")
                    }
                }
                //                }
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
//        ZStack {
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
                                        .foregroundColor(newShoppingListTextField.isEmpty ? Color.white : Color.pink.opacity(0.5))
                                        .cornerRadius(8)
                                } else {
                                    Text("追加")
                                        .padding()
                                        .foregroundColor(newShoppingListTextField.isEmpty ? Color.gray : Color.pink)
                                        .cornerRadius(8)
                                }
                            }
                            .disabled(newShoppingListTextField.isEmpty)
                        }
                        ForEach(category.items) { item in
                            HStack {
                                Image(systemName: item.isChecked ? "checkmark.square" : "square")
                                    .foregroundStyle(item.isChecked ? .green : .red)
                                    .scaleEffect(item.isChecked ? 0.7 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.2), value: item.isChecked)
                                
                                Text(item.name)
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
                        .frame(height: 35)
                    }
                }
                .environment(\.defaultMinListRowHeight, 3)
                .scrollContentBackground(.hidden)
                .background(
                    Color.shoppingListBack
                )
                
//                HStack {
//                    TextField("入力してください", text: $newShoppingListTextField)
//                        .padding()
//                        .foregroundColor(Color.black)
//                    Button(action: {
//                        addShoppingList()
//                        buttonAnalytics()
//                    }) {
//                        if colorScheme == .dark {
//                            Text("追加")
//                                .padding()
//                                .foregroundColor(newShoppingListTextField.isEmpty ? Color.white : Color.pink.opacity(0.5))
//                                .cornerRadius(8)
//                        } else {
//                            Text("追加")
//                                .padding()
//                                .foregroundColor(newShoppingListTextField.isEmpty ? Color.gray : Color.pink)
//                                .cornerRadius(8)
//                        }
//                    }
//                    .disabled(newShoppingListTextField.isEmpty)
//                }
//                .background(colorScheme == .dark ? Color.gray : Color.white)
//                .cornerRadius(10)
//                .frame(height: 70)
//                .shadow(radius: 3)
//                .padding()
            }
//        } // ZStack
        .onAppear {
            Analytics.logEvent(AnalyticsEventScreenView, parameters: [
                AnalyticsParameterScreenName: "ItemListView",
                AnalyticsParameterScreenClass: "ItemListView"
            ])
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) // デフォルトの戻るボタンを非表示
//        .toolbar(.hidden, for: .tabBar) // タブバーを非表示にする
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
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
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
