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
    @Persisted var regularItems = RealmSwift.List<RegularItemViewModel>()
    
    convenience init(name: String, items: [String]) {
        self.init()
        self.name = name
        self.items.append(objectsIn: items.map { Item(name: $0) }) // 変換して追加
    }
    
    // アイテム数を返すプロパティ
    var itemCount: Int {
        return items.count
    }
    // 未チェックアイテムの数を返すプロパティ
    var uncheckedItemCount: Int {
        return items.filter { !$0.isChecked }.count
    }
}


// MARK: CategoryListView
struct CategoryListView: View {
    
    @State private var isCategoryAdditionAlert = false // カテゴリー追加アラート
    @State private var newCategoryTextField = "" // NEWカテゴリーTextField
    @State private var sortOption: SortOption = .default // 並び替え
    @ObservedResults(CategoryListModel.self) var categories
    
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
            return Array(categories)
        case .nameAscending:
            return categories.sorted(by: { $0.name < $1.name })
        case .nameDescending:
            return categories.sorted(by: { $0.name > $1.name })
        case.itemCountAscending:
            return categories.sorted(by: { $0.itemCount < $1.itemCount })
        case .itemCountDescending:
            return categories.sorted(by: { $0.itemCount > $1.itemCount })
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
                                .disabled(categories.isEmpty)
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
        let newCategory = CategoryListModel(name: newCategoryTextField, items: [])
        try! realm.write {
            $categories.append(newCategory)
        }
        newCategoryTextField = ""
    }
    
    private func deleteCategory(at offsets: IndexSet) {
        let realm = try! Realm()
        try! realm.write {
            // 削除対象のアイテムを削除
            $categories.remove(atOffsets: offsets)
        }
    }
}

// MARK: ItemListView
struct ItemListView: View {
    
    @State private var isShoppingListAdditionAlert = false
    @State private var newShoppingListTextField = ""
    
    @State var category: CategoryListModel?
    
    var categoryId: String
    
    var body: some View {
        VStack {
            List(category?.items ?? List<Item>()) { item in
                HStack {
                    Image(systemName: item.isChecked ? "checkmark.square" : "square")
                        .foregroundStyle(item.isChecked ? .green : .red)
                        .scaleEffect(item.isChecked ? 1.2 : 1.0) // チェック時にアイコンが少し大きくなる
                        .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.2), value: item.isChecked)
                    
                    Text(item.name)
                        .foregroundStyle(item.isChecked ? Color.gray : Color.black)
                        .strikethrough(item.isChecked, color: .gray) // チェック時に取り消し線
                        .animation(.easeOut, value: item.isChecked)
                    
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        toggleCheckState(for: item) // アニメーションでチェック状態を切り替え
                    }
                }
            } // List
        }
        .navigationTitle(category?.name ?? "")
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
                        }
                    }
                    Menu("メニュー", systemImage: "ellipsis") {
                        Button(action: {
                            
                        }) {
                            Text("並び替え")
                            Image(systemName: "arrow.up.and.down.text.horizontal")
                        }
                    }
                }
            }
        } // toolbar
        .onAppear {
            loadShoppingList()
        }
    }
    
    private func addShoppingList() {
        guard !newShoppingListTextField.isEmpty else { return }
        let realm = try! Realm()
        let newItem = Item(name: newShoppingListTextField)
        try! realm.write {
            category?.items.append(newItem)
        }
        newShoppingListTextField = ""
    }
    
    private func loadShoppingList() {
        // Realmからデータを取得
        let realm = try! Realm()
        if let category = realm.object(ofType: CategoryListModel.self, forPrimaryKey: categoryId) {
            self.category = category
        }
    }
    
    private func toggleCheckState(for item: Item) {
        let realm = try! Realm()
        try! realm.write {
            item.isChecked.toggle() // チェック状態を切り替え
        }
    }
}


#Preview {
    CategoryListView()
}
