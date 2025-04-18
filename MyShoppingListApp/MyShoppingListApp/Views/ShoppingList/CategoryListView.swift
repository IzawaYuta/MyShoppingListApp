//
//  CategoryListView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/03/21.
//

import SwiftUI
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
    @State private var sortOption: SortOption = .default // 並び替え
    @State private var isModalPresented = false
    @ObservedResults(CategoryListModel.self) var categoryListModel
    
    enum SortOption: String, CaseIterable {
        case `default` = "デフォルト順"
        case nameAscending = "名前昇順"
        case nameDescending = "名前降順"
        case itemCountAscending = "アイテム数昇順"
        case itemCountDescending = "アイテム数降順"
    }
    
    var sortedCategories: [CategoryListModel] {
        switch sortOption {
        case .default:
            return Array(categoryListModel)
        case .nameAscending:
            return categoryListModel.sorted(by: { $0.name < $1.name })
        case .nameDescending:
            return categoryListModel.sorted(by: { $0.name > $1.name })
        case.itemCountAscending:
            return categoryListModel.sorted(by: { $0.itemCount < $1.itemCount })
        case .itemCountDescending:
            return categoryListModel.sorted(by: { $0.itemCount > $1.itemCount })
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // sortedCategoriesが空の場合にメッセージを表示
                if categoryListModel.isEmpty {
                    Text("カテゴリーを追加しましょう！")
                        .foregroundColor(.gray) // 文字色を指定することも可能
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // 中央に表示
                } else {
                    List {
                        ForEach(sortedCategories) { category in
                            NavigationLink(destination: ItemListView(category: category, categoryId: category.id)) {
                                HStack {
                                    //                                    VStack {
                                    Text(category.name)
                                    if category.isOn {
                                        Image(systemName: "person.2.fill")
                                            .font(.system(size: 15))
                                            .foregroundColor(.gray)
                                        //                                        }
                                    }
                                    Spacer()
                                    Text("\(category.uncheckedItemCount)/\(category.itemCount)")
                                        .foregroundColor(.gray)
                                } ///HStack
                            }
                        }
                        .onDelete(perform: deleteCategory)
                    }
                }
            }
            .navigationTitle("カテゴリー")
            .toolbar(.visible, for:.tabBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
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
                }
                ToolbarItem(placement: .topBarLeading) {
                    Menu("メニュー", systemImage: "arrow.up.arrow.down") {
                        Picker("並び替え", selection: $sortOption) {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    Button(action: {
                        isModalPresented = true
                    }) {
                        Text("リストを共有")
                    }
                    .sheet(isPresented: $isModalPresented) {
                        ShareView()
                    }
                }
                //                }
            }
        } /// NavigationView
    }
    
    
    private func addCategory() {
        guard !newCategoryTextField.isEmpty else {
            // テキストフィールドが空なら何もしない
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
            // 削除対象のアイテムを削除
            $categoryListModel.remove(atOffsets: offsets)
        }
    }
}

// MARK: ItemListView
struct ItemListView: View {
    
    @State private var isShoppingListAdditionAlert = false
    @State private var newShoppingListTextField = ""
    @State private var isTrash = false
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedRealmObject var category: CategoryListModel
    
    var categoryId: String
    
    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                ForEach(category.items) { item in
                    HStack {
                        Image(systemName: item.isChecked ? "checkmark.square" : "square")
                            .foregroundStyle(item.isChecked ? .green : .red)
                            .scaleEffect(item.isChecked ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.2), value: item.isChecked)
                        
                        Text(item.name)
//                            .foregroundStyle(item.isChecked ? Color.gray : Color.black)
                            .strikethrough(item.isChecked, color: .gray)
                            .animation(.easeOut, value: item.isChecked)
                        
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            toggleCheckState(for: item)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            HStack {
                TextField("入力してください", text: $newShoppingListTextField)
                    .padding()
                    .foregroundColor(Color.primary)
                
                Button(action: {
                    addShoppingList()
                }) {
                    Text("追加")
                        .padding()
                        .foregroundColor(newShoppingListTextField.isEmpty ? Color.gray : Color.pink)
                        .cornerRadius(8)
                }
                .disabled(newShoppingListTextField.isEmpty)
            }
            .background(Color.white)
            .cornerRadius(10)
            .frame(height: 130)
            .shadow(radius: 3)
            .padding()
        } // VStack
        .navigationBarTitleDisplayMode(.inline)
//        .navigationBarBackButtonHidden(true) // デフォルトの戻るボタンを非表示
        .toolbar(.hidden, for: .tabBar) // タブバーを非表示にする
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
}


#Preview {
    CategoryListView()
}
