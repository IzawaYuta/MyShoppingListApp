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
    
//    var regularItemsCount: Int {
//        return regularItems.count
//    }
}


// MARK: CategoryListView
struct CategoryListView: View {
    
    @State private var isCategoryAdditionAlert = false // カテゴリー追加アラート
    @State private var newCategoryTextField = "" // NEWカテゴリーTextField
    @State private var sortOption: SortOption = .default // 並び替え
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
            List {
                ForEach(sortedCategories) { category in
                    NavigationLink(destination: ItemListView(category: category, categoryId: category.id)) {
                        HStack {
                            Text(category.name)
                            Spacer()
                            Text("\(category.uncheckedItemCount)/\(category.itemCount)")
                                .foregroundColor(.gray)
                        } ///HStack
                    }
                }
                .onDelete(perform: deleteCategory)
            }
            .navigationTitle("カテゴリー")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isCategoryAdditionAlert.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                    .alert("カテゴリーを追加", isPresented: $isCategoryAdditionAlert) {
                        TextField("カテゴリー名", text: $newCategoryTextField)
                        Button("キャンセル", role: .cancel){
                        }
                        Button("追加") {
                            addCategory()
                        }
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Menu("メニュー", systemImage: "ellipsis") {
                            Picker("並び替え", selection: $sortOption) {
                                ForEach(SortOption.allCases, id: \.self) { option in
                                    Text(option.rawValue).tag(option)
                                } 
                        }
                        .pickerStyle(MenuPickerStyle())
                            // TODO: Imageを変更する
                                ShareLink(item: "カテゴリー共有", preview: SharePreview("メッセージです", image: Image("MyImage"))) {
                                    Label("カテゴリーを共有", systemImage: "square.and.arrow.up")
                                }
                                .disabled(categoryListModel.isEmpty)
                    }
                }
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
    
    @ObservedRealmObject var category: CategoryListModel

    var categoryId: String
    
    var body: some View {
        VStack {
            List {
                ForEach(category.items) { item in
                    HStack {
                        Image(systemName: item.isChecked ? "checkmark.square" : "square")
                            .foregroundStyle(item.isChecked ? .green : .red)
                            .scaleEffect(item.isChecked ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.2), value: item.isChecked)
                        
                        Text(item.name)
                            .foregroundStyle(item.isChecked ? Color.gray : Color.black)
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

        }
        .navigationTitle(category.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {
                        isShoppingListAdditionAlert.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                    .alert("リストを追加", isPresented: $isShoppingListAdditionAlert) {
                        TextField("買うもの", text: $newShoppingListTextField)
                        Button("キャンセル", role: .cancel) {
                        }
                        Button("追加") {
                            addShoppingList()
                            print("\(category.items)")
                        }
                    }
                    Menu("メニュー", systemImage: "ellipsis") {
                        Button(action: {
                            
                        }) {
                            Text("並び替え")
                            Image(systemName: "arrow.up.and.down.text.horizontal")
                        }
                        Button(action: {
                            deleteCheckedItems()
                        }) {
                            Image(systemName: "trash")
                        }
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
                    realm.delete(item)
                }
            }
        }
    }
}


#Preview {
    CategoryListView()
}






//import SwiftUI
//import RealmSwift
//
//// MARK: Item
//class Item: Object, Identifiable {
//    @Persisted var id = UUID()
//    @Persisted var name: String = ""
//    @Persisted var isChecked: Bool = false
//    
//    convenience init(name: String) {
//        self.init()
//        self.name = name
//    }
//}
//
//// MARK: CategoryListModel
//class CategoryListModel: Object, Identifiable {
//    @Persisted(primaryKey: true) var id: String = UUID().uuidString
//    @Persisted var name: String = ""
//    @Persisted var items = RealmSwift.List<Item>()
//    @Persisted var regularItems = RealmSwift.List<RegularItemViewModel>()
//    
//    convenience init(name: String, items: [String], regularItems : [String]) {
//        self.init()
//        self.name = name
//        self.items.append(objectsIn: items.map { Item(name: $0) }) // 変換して追加
//        self.regularItems.append(objectsIn: regularItems.map { RegularItemViewModel(regularName: $0, categoryID: $0) })
//    }
//    
//    var itemCount: Int {
//        return items.count
//    }
//    var uncheckedItemCount: Int {
//        return items.filter { !$0.isChecked }.count
//    }
//    
//    //    var regularItemsCount: Int {
//    //        return regularItems.count
//    //    }
//}
//
//
//// MARK: CategoryListView
//struct CategoryListView: View {
//    
//    @State private var isCategoryAdditionAlert = false // カテゴリー追加アラート
//    @State private var newCategoryTextField = "" // NEWカテゴリーTextField
//    @State private var sortOption: SortOption = .default // 並び替え
//    @ObservedResults(CategoryListModel.self) var categoryListModel
//    
//    enum SortOption: String, CaseIterable {
//        case `default` = "デフォルト順"
//        case nameAscending = "名前昇順"
//        case nameDescending = "名前降順"
//        case itemCountAscending = "アイテム数昇順"
//        case itemCountDescending = "アイテム数降順"
//    }
//    
//    var sortedCategories: [CategoryListModel] {
//        switch sortOption {
//        case .default:
//            return Array(categoryListModel)
//        case .nameAscending:
//            return categoryListModel.sorted(by: { $0.name < $1.name })
//        case .nameDescending:
//            return categoryListModel.sorted(by: { $0.name > $1.name })
//        case.itemCountAscending:
//            return categoryListModel.sorted(by: { $0.itemCount < $1.itemCount })
//        case .itemCountDescending:
//            return categoryListModel.sorted(by: { $0.itemCount > $1.itemCount })
//        }
//    }
//    
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(sortedCategories) { category in
//                    NavigationLink(destination: ItemListView(category: category, categoryId: category.id)) {
//                        HStack {
//                            Text(category.name)
//                            Spacer()
//                            Text("\(category.uncheckedItemCount)/\(category.itemCount)")
//                                .foregroundColor(.gray)
//                        } ///HStack
//                    }
//                }
//                .onDelete(perform: deleteCategory)
//            }
//            .navigationTitle("カテゴリー")
//            .toolbar {
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button(action: {
//                        isCategoryAdditionAlert.toggle()
//                    }) {
//                        Image(systemName: "plus")
//                    }
//                    .alert("カテゴリーを追加", isPresented: $isCategoryAdditionAlert) {
//                        TextField("カテゴリー名", text: $newCategoryTextField)
//                        Button("キャンセル", role: .cancel){
//                        }
//                        Button("追加") {
//                            addCategory()
//                        }
//                    }
//                }
//                ToolbarItem(placement: .topBarLeading) {
//                    Menu("メニュー", systemImage: "ellipsis") {
//                        Picker("並び替え", selection: $sortOption) {
//                            ForEach(SortOption.allCases, id: \.self) { option in
//                                Text(option.rawValue).tag(option)
//                            }
//                        }
//                        .pickerStyle(MenuPickerStyle())
//                        // TODO: Imageを変更する
//                        ShareLink(item: "カテゴリー共有", preview: SharePreview("メッセージです", image: Image("MyImage"))) {
//                            Label("カテゴリーを共有", systemImage: "square.and.arrow.up")
//                        }
//                        .disabled(categoryListModel.isEmpty)
//                    }
//                }
//            }
//        } /// NavigationView
//    }
//    
//    private func addCategory() {
//        guard !newCategoryTextField.isEmpty else {
//            // テキストフィールドが空なら何もしない
//            return
//        }
//        let realm = try!Realm()
//        let newCategory = CategoryListModel(name: newCategoryTextField, items: [], regularItems: [])
//        try! realm.write {
//            $categoryListModel.append(newCategory)
//        }
//        newCategoryTextField = ""
//    }
//    
//    private func deleteCategory(at offsets: IndexSet) {
//        let realm = try! Realm()
//        try! realm.write {
//            // 削除対象のアイテムを削除
//            $categoryListModel.remove(atOffsets: offsets)
//        }
//    }
//}
//
//// MARK: ItemListView
//struct ItemListView: View {
//    
//    @State private var isShoppingListAdditionAlert = false
//    @State private var newShoppingListTextField = ""
//    
//    @ObservedRealmObject var category: CategoryListModel
//    
//    var categoryId: String
//    
//    var body: some View {
//        VStack {
//            List {
//                ForEach(category.items) { item in
//                    HStack {
//                        Image(systemName: item.isChecked ? "checkmark.square" : "square")
//                            .foregroundStyle(item.isChecked ? .green : .red)
//                            .scaleEffect(item.isChecked ? 1.2 : 1.0)
//                            .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.2), value: item.isChecked)
//                        
//                        Text(item.name)
//                            .foregroundStyle(item.isChecked ? Color.gray : Color.black)
//                            .strikethrough(item.isChecked, color: .gray)
//                            .animation(.easeOut, value: item.isChecked)
//                        
//                        Spacer()
//                    }
//                    .contentShape(Rectangle())
//                    .onTapGesture {
//                        withAnimation {
//                            toggleCheckState(for: item)
//                        }
//                    }
//                }
//            }
//            
//        }
//        .navigationTitle(category.name)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                HStack {
//                    Button(action: {
//                        isShoppingListAdditionAlert.toggle()
//                    }) {
//                        Image(systemName: "plus")
//                    }
//                    .alert("リストを追加", isPresented: $isShoppingListAdditionAlert) {
//                        TextField("買うもの", text: $newShoppingListTextField)
//                        Button("キャンセル", role: .cancel) {
//                        }
//                        Button("追加") {
//                            addShoppingList()
//                            print("\(category.items)")
//                        }
//                    }
//                    Menu("メニュー", systemImage: "ellipsis") {
//                        Button(action: {
//                            
//                        }) {
//                            Text("並び替え")
//                            Image(systemName: "arrow.up.and.down.text.horizontal")
//                        }
//                        Button(action: {
//                            deleteCheckedItems()
//                        }) {
//                            Image(systemName: "trash")
//                        }
//                    }
//                }
//            }
//        } // toolbar
//    }
//    
//    private func addShoppingList() {
//        let realm = try! Realm()
//        guard !newShoppingListTextField.isEmpty else { return }
//        let newItem = Item(name: newShoppingListTextField)
//        try! realm.write {
//            $category.items.append(newItem)
//        }
//        newShoppingListTextField = ""
//    }
//    
//    private func toggleCheckState(for item: Item) {
//        let realm = try! Realm()
//        // itemをthawして変更できるようにする
//        if let thawedItem = item.thaw() {
//            try! realm.write {
//                thawedItem.isChecked.toggle()
//            }
//        }
//    }
//    private func deleteCheckedItems() {
//        let realm = try! Realm()
//        
//        // category.itemsをthawして変更できるようにする
//        if let thawedCategory = category.thaw() {
//            let checkedItems = thawedCategory.items.filter { $0.isChecked }
//            
//            try! realm.write {
//                for item in checkedItems {
//                    realm.delete(item)
//                }
//            }
//        }
//    }
//}
//
//
//#Preview {
//    CategoryListView()
//}
