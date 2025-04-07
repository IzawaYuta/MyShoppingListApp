////
////  RegularListView.swift
////  MyShoppingListApp
////
////  Created by Engineer MacBook Air on 2025/03/21.
////
//
//import SwiftUI
//import RealmSwift
//
//// MARK: RegularListViewModel
//class RegularItemViewModel: Object, Identifiable {
//    @Persisted(primaryKey: true) var id: String = UUID().uuidString
//    @Persisted var regularName: String = ""
//    @Persisted var regularID: String = "" // カテゴリーIDを追加
//    
//    convenience init(regularName: String, regularID: String) {
//        self.init()
//        self.regularName = regularName
//        self.regularID = regularID
//    }
//}
//
//// MARK: RegularCategoryListView
//struct RegularCategoryListView: View {
//    @ObservedResults(CategoryListModel.self) var categoryListModel
//    var body: some View {
//        NavigationStack {
//            List(categoryListModel) { list in
//                NavigationLink(destination: RegularItemView(categoryListModel: list, regularItemId: list.id, regularID: String())) {
//                    Text(list.name)
//                }
//            }
//            .navigationTitle("定期リスト")
//        }
//    }
//}
//
//// MARK: RegularItemView
//struct RegularItemView: View {
//    
//    @State private var isRegularItemAdditionAlert = false
//    @State private var newRegularItemTextField = ""
//    @ObservedResults(RegularItemViewModel.self) var regularItemViewModel
//    @State var categoryListModel: CategoryListModel?
//    @State private var selectedItems = Set<String>() // 選択されたアイテムを追跡
//    @State private var selectAllItemsBool = false
//    
//    var regularItemId: String
//    let regularID: String
//    
//    let realm = try! Realm()
//    
//    var body: some View {
//        NavigationStack {
//            List {
//                ForEach(categoryListModel?.regularItems ?? List<RegularItemView>()) { list in
////                ForEach(regularItemViewModel.filter { $0.regularID == regularItemId }) { list in
//                    HStack {
//                        Image(systemName: selectedItems.contains(list.id) ? "checkmark.circle.fill" : "circle")
//                            .scaleEffect(selectedItems.contains(list.id) ? 1.3 : 1.0)
//                            .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.2), value: selectedItems)
//                        Text(list.regularName)
//                        
//                        Spacer()
//                    }
//                    .contentShape(Rectangle())
//                    .onTapGesture {
//                        toggleSelection(for: list)
//                    }
//                }
//                .onDelete(perform: deleteRegularItem)
//            }
//            .navigationTitle("\(categoryListModel?.name ?? "")の定期リスト")
//        } // NavigationStack
//        .toolbar {
//            ToolbarItem(placement: .topBarTrailing) {
//                HStack {
//                    if selectedItems == [] {
//                    } else {
//                        Button(action: {
//                            saveSelectedItems()
//                        }) {
//                            Image(systemName: "arrow.up")
//                        }
//                    }
//                    Button(action: {
//                        selectAllItemsBool.toggle()
//                        selectAllItems()
//                    }) {
//                        Image(systemName: selectedItems.count == (categoryListModel?.regularItems.count ?? 0) ? "xmark.circle" : "checkmark.circle")
//                    }
//                    Button(action: {
//                        isRegularItemAdditionAlert.toggle()
//                    }) {
//                        Image(systemName: "plus")
//                    }
//                    .alert("定期品の追加", isPresented: $isRegularItemAdditionAlert) {
//                        TextField("定期品", text: $newRegularItemTextField)
//                        Button("追加") {
//                            addRegularItem()
//                        }
//                        Button("キャンセル", role: .cancel) {
//                        }
//                    }
//                }
//            }
//        }
//        .onAppear {
//            loadRegularItem()
//        }
//    } // vat body: some View
//    
////    private func addRegularItem() {
////        guard !newRegularItemTextField.isEmpty else {
////            return
////        }
////        let realm = try! Realm()
////        let addRegularItem = RegularItemViewModel(regularName: newRegularItemTextField)
////        try! realm.write {
////            // 新しい定期品を regularItems に追加
////            categoryListModel?.regularItems.append(addRegularItem)
////        }
////        newRegularItemTextField = ""
////        print("定期品⚠️\(regularItemViewModel)")
////        print("カテゴリー♥️\(categoryListModel?.regularItems)")
////    }
//    
//    
//    private func addRegularItem() {
//        guard !newRegularItemTextField.isEmpty, let regularID = categoryListModel?.id else {
//            return
//        }
//        
//        let realm = try! Realm()
//        let addRegularItem = RegularItemViewModel(regularName: newRegularItemTextField, regularID: regularID)
//        print("📌 追加しようとしている定期品: \(addRegularItem)")
//
//        try! realm.write {
//            // 新しい定期品をカテゴリーの `regularItems` に追加
//            categoryListModel?.regularItems.append(addRegularItem)
//            print("✅ Realm に追加後の CategoryListModel の regularItems: \(categoryListModel?.regularItems)")
////            $regularItemViewModel.append(addRegularItem)
//        }
//        DispatchQueue.main.async {
//            self.$regularItemViewModel.append(addRegularItem)
//            print("📌 RegularItemViewModel に追加後の中身: \(regularItemViewModel)")
//        }
//
//        newRegularItemTextField = ""
//    }
//
//    
//    private func loadRegularItem() {
//        // Realmから CategoryListModel を取得
//        let realm = try! Realm()
//        if let category = realm.object(ofType: CategoryListModel.self, forPrimaryKey: regularItemId) {
//            self.categoryListModel = category
//            
////            // 取得したデータを出力
////            print("Category Name: \(category.name)")
////            print("Regular Items Count: \(category.regularItems.count)")
////            for item in category.regularItems {
////                print("Regular Item Name: \(item.regularName), ID: \(item.regularID)")
////            }
////        } else {
////            print("Category with ID \(regularItemId) not found")
//        }
//        print("カテゴリーの中身😀\(categoryListModel)")
//        print("定期品の中身💬\(regularItemViewModel)")
//    }
//
//
//    
//    // 選択状態を切り替える
//    private func toggleSelection(for item: RegularItemViewModel) {
//        if selectedItems.contains(item.id) {
//            selectedItems.remove(item.id)
//        } else {
//            selectedItems.insert(item.id)
//        }
//    }
//
//    
//    private func saveSelectedItems() {
//        guard let regularItems = categoryListModel else { return }
//        
//        let realm = try! Realm()
//        try! realm.write {
//            // 選択されたアイテムをフィルタリング
//            let selectedRegularItems = regularItemViewModel.filter { selectedItems.contains($0.id) }
//            
//            // 必要に応じて型を変換
//            let convertedItems = selectedRegularItems.map { regularItem in
//                let item = Item() // Item は CategoryListModel の items に対応する型
//                item.name = regularItem.regularName
//                // 必要に応じて他のプロパティも設定
//                return item
//            }
//            
//            // items に追加
//            regularItems.items.append(objectsIn: convertedItems)
//        }
//    }
//    
//    // リストの全選択
//    private func selectAllItems() {
//        guard let regularItems = categoryListModel else { return }
//        if selectedItems.count == regularItems.regularItems.count {
//            // 全選択されている場合、選択解除
//            selectedItems.removeAll()
//        } else {
//            // 全選択されていない場合、全て選択
//            selectedItems = Set(regularItems.regularItems.map { $0.id })
//        }
//    }
////    
////    private func deleteRegularItem(at offsets: IndexSet) {
////        guard let category = categoryListModel else {
////            print("⚠️ categoryListModel が nil です")
////            return
////        }
////        
////        let realm = try! Realm()
////        
////        try! realm.write {
////            // 削除するアイテムを取り出す
////            let itemsToDelete = offsets.map { category.regularItems[$0] }
////            print("🗑️ 削除予定のアイテム: \(itemsToDelete.map { $0.regularName })")
////            
////            // Realm から削除
////            for item in itemsToDelete {
////                if let index = category.regularItems.firstIndex(where: { $0.regularName == item.regularName && $0.regularID == item.regularID }) {
////                    category.regularItems.remove(at: index)
////                    print("✅ Realm から削除したアイテム: \(item.regularName)")
////                } else {
////                    print("⚠️ Realm で削除対象アイテムが見つかりません: \(item.regularName)")
////                }
////            }
////        }
////        
////        // regularItemViewModel から削除
////        for item in offsets.map({ regularItemViewModel[$0] }) {
////            if let index = regularItemViewModel.firstIndex(where: { $0.regularName == item.regularName && $0.regularID == item.regularID }) {
////                $regularItemViewModel.remove(at: index)
////                print("✅ regularItemViewModel から削除したアイテム: \(item.regularName)")
////            } else {
////                print("⚠️ regularItemViewModel で削除対象アイテムが見つかりません: \(item.regularName)")
////            }
////        }
////        
////        // 削除後の状態を確認
////        print("🔄 削除後の regularItems: \(categoryListModel?.regularItems)")
////        print("🔄 削除後の regularItemViewModel: \(regularItemViewModel)")
////    }
//    
//    
//    
//    
//    
////    private func deleteRegularItem(at offsets: IndexSet) {
////        guard let category = categoryListModel else {
////            print("⚠️ categoryListModel が nil です")
////            return
////        }
////        
////        let realm = try! Realm()
////        
////        // 削除するアイテムを取得
////        let itemsToDelete = offsets.map { category.regularItems[$0] }
////        print("🗑️ 削除予定のアイテム: \(itemsToDelete.map { $0.regularName })")
////        
////        try! realm.write {
////            // Realm から削除
////            for item in itemsToDelete {
////                if let index = category.regularItems.firstIndex(where: { $0.regularName == item.regularName && $0.regularID == item.regularID }) {
////                    category.regularItems.remove(at: index)
////                    print("✅ Realm から削除したアイテム: \(item.regularName)")
////                } else {
////                    print("⚠️ Realm で削除対象アイテムが見つかりません: \(item.regularName)")
////                }
////            }
////        }
////        
////        // regularItemViewModel を削除可能な配列に変換して操作
//////        let regularItemsArray = Array(regularItemViewModel)
//////        var updatedRegularItems = regularItemsArray
//////        
//////        for item in itemsToDelete {
//////            if let index = updatedRegularItems.firstIndex(where: { $0.regularName == item.regularName && $0.regularID == item.regularID }) {
//////                updatedRegularItems.remove(at: index)
//////                print("✅ regularItemViewModel 配列から削除したアイテム: \(item.regularName)")
//////            } else {
//////                print("⚠️ regularItemViewModel 配列で削除対象アイテムが見つかりません: \(item.regularName)")
//////            }
//////        }
////        
////        
////        // 削除するオブジェクトを取得
//////        let itemsToDelete2 = offsets.map { regularItemViewModel[$0] }
//////        print("🗑️ 削除予定のアイテム: \(itemsToDelete2.map { $0.regularName })")
//////        
//////        // Realm の書き込みトランザクション内で削除
//////        try! realm.write {
//////            for item in itemsToDelete2 {
//////                if let object = realm.object(ofType: RegularItemViewModel.self, forPrimaryKey: item.id) {
//////                    realm.delete(object)
//////                }
//////            }
//////        }
////        let itemsToDelete2 = offsets.map { regularItemViewModel[$0] }
////        print("🗑️ 削除予定のアイテム: \(itemsToDelete2.map { $0.regularName })")
////        
////        // Realm の書き込みトランザクション内で削除
////        try! realm.write {
////            for item in itemsToDelete2 {
////                // 削除対象アイテムの regularID と regularName を取得
////                let regularID = item.regularID
////                let regularName = item.regularName
////                
////                // `RegularItemViewModel` で一致するデータを取得
////                if let objectToDelete = realm.objects(RegularItemViewModel.self).first(where: {
////                    $0.regularID == regularID && $0.regularName == regularName
////                }) {
////                    // 一致したデータが見つかった場合、そのデータを削除
////                    realm.delete(objectToDelete)
//////                    print("🗑️ 削除したアイテム: \(objectToDelete.regularName)")
////                } else {
//////                    print("⚠️ 削除対象アイテムが見つかりませんでした: \(regularName)")
////                }
////            }
////        }
////
////
////        
////        // 削除後の状態を確認
////        print("🔄 削除後の RegularItemViewModel: \(regularItemViewModel.map { $0.regularName })")
////        
////        // regularItemViewModel を更新
//////        regularItemViewModel = updatedRegularItems
////        
////        // 削除後の状態を確認
////        print("🔄 削除後の regularItems: \(categoryListModel?.regularItems)")
////        print("🔄 削除後の regularItemViewModel: \(RegularItemViewModel())")
////    }
//
//
//
//    private func deleteRegularItem(at offsets: IndexSet) {
//        guard let category = categoryListModel else {
//            print("⚠️ categoryListModel が nil です")
//            return
//        }
//        
//        let realm = try! Realm()
//        
//        // 削除するアイテムを取得（`offsets` に基づいて）
//        let itemsToDelete = offsets.map { category.regularItems[$0] }
//        print("🗑️ 削除予定のアイテム: \(itemsToDelete.map { $0.regularName })")
//        
//        try! realm.write {
//            // 削除対象のアイテムをRealmから削除
//            for item in itemsToDelete {
//                // 削除対象アイテムの regularID と regularName を取得
//                let regularID = item.regularID
//                let regularName = item.regularName
//                
//                // `RegularItemViewModel` で一致するデータを取得
//                if let objectToDelete = realm.objects(RegularItemViewModel.self).first(where: {
//                    $0.regularID == regularID && $0.regularName == regularName
//                }) {
//                    // 一致したデータが見つかった場合、そのデータを削除
//                    realm.delete(objectToDelete)
////                    print("🗑️ 削除したアイテム: \(objectToDelete.regularName)")
//                    
//                    // `category.regularItems` 配列からも削除
//                    if let index = category.regularItems.firstIndex(where: { $0.regularID == regularID && $0.regularName == regularName }) {
//                        category.regularItems.remove(at: index)
//                        print("✅ category.regularItems から削除したアイテム: \(regularName)")
//                    } else {
//                        print("⚠️ category.regularItems で削除対象アイテムが見つかりません: \(regularName)")
//                    }
//                } else {
//                    print("⚠️ 削除対象アイテムが Realm で見つかりませんでした: \(regularName)")
//                }
//            }
//        }
//    }
//
//    
////    func deleteItem(at offsets: IndexSet) {
////        let realm = try! Realm()
////        try! realm.write {
////            $regularItemViewModel.remove(atOffsets: offsets)
////        }
////    }
//    
////    private func deleteItems(at offsets: IndexSet) {
////        // 正しい Realm インスタンスを取得
////        let realm = try! Realm()
////        
////        // 削除対象のアイテムを取得する
////        offsets.forEach { index in
////            let itemToDelete = regularItemViewModel.filter { $0.regularID == regularItemId }[index]
////            
////            // Realm インスタンスが一致していることを確認
////            guard let realmObject = realm.object(ofType: RegularItemViewModel.self, forPrimaryKey: itemToDelete.id) else {
////                print("アイテムが見つかりませんでした")
////                return
////            }
////            
////            // Realm から削除
////            try! realm.write {
////                realm.delete(realmObject)
////            }
////        }
////    }
//    
//    // リスト項目の削除処理
////    private func deleteRegularItem(at offsets: IndexSet) {
////        guard let category = categoryListModel else { return }
////        
////        // Realmのトランザクションで削除
////        let realm = try! Realm()
////        try! realm.write {
////            // 削除対象のアイテムを定期品リストから削除
////            offsets.forEach { index in
////                let item = category.regularItems[index]
////                category.regularItems.remove(at: index)
////                print("Deleted item: \(item.regularName)") // 削除されたアイテム名のログ出力
////            }
////        }
////        loadRegularItem() // これによりデータが再読み込みされて、画面が更新される
////        print("\(category.regularItems)")
////    }
//
//
//
//
//
//
//
//
//
//}
//
//#Preview {
//    RegularCategoryListView()
//}
