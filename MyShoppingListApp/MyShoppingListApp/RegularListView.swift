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
    @State private var selectedItems = Set<UUID>() // 選択されたアイテムを追跡
    @State private var selectAllItemsBool = false
    
    var regularItemId: String
    
    var body: some View {
        NavigationStack {
            List(regularItems?.regularItems ?? List<RegularItemView>()) { list in
                HStack {
                    Image(systemName: selectedItems.contains(list.id) ? "checkmark.circle.fill" : "circle")
                        .scaleEffect(selectedItems.contains(list.id) ? 1.3 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.2), value: selectedItems)
                    Text(list.regularName)
                    
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    toggleSelection(for: list)
                }
            }
            .navigationTitle("\(regularItems?.name ?? "")の定期リスト")
        } // NavigationStack
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    if selectedItems == [] {
                    } else {
                        Button(action: {
                            saveSelectedItems()
                        }) {
                            Image(systemName: "arrow.up")
                        }
                    }
                    Button(action: {
                        selectAllItemsBool.toggle()
                        selectAllItems()
                    }) {
                        Image(systemName: selectedItems.count == (regularItems?.regularItems.count ?? 0) ? "xmark.circle" : "checkmark.circle")
                    }
                    Button(action: {
                        isRegularItemAdditionAlert.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                    .alert("定期品の追加", isPresented: $isRegularItemAdditionAlert) {
                        TextField("定期品", text: $newRegularItemTextField)
                        Button("追加") {
                            addRegularItem()
                        }
                        Button("キャンセル", role: .cancel) {
                        }
                    }
                }
            }
        }
        .onAppear {
            loadRegularItem()
        }
    } // vat body: some View
    
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
        }
    }
    
    // 選択状態を切り替える
    private func toggleSelection(for item: RegularItemViewModel) {
        if selectedItems.contains(item.id) {
            selectedItems.remove(item.id)
        } else {
            selectedItems.insert(item.id)
        }
    }
    
    private func saveSelectedItems() {
        guard let regularItems = regularItems else { return }
        
        let realm = try! Realm()
        try! realm.write {
            // 選択されたアイテムをフィルタリング
            let selectedRegularItems = regularItemViewModel.filter { selectedItems.contains($0.id) }
            
            // 必要に応じて型を変換
            let convertedItems = selectedRegularItems.map { regularItem in
                let item = Item() // Item は CategoryListModel の items に対応する型
                item.name = regularItem.regularName
                // 必要に応じて他のプロパティも設定
                return item
            }
            
            // items に追加
            regularItems.items.append(objectsIn: convertedItems)
        }
    }
    
    // リストの全選択
    private func selectAllItems() {
        guard let regularItems = regularItems else { return }
        if selectedItems.count == regularItems.regularItems.count {
            // 全選択されている場合、選択解除
            selectedItems.removeAll()
        } else {
            // 全選択されていない場合、全て選択
            selectedItems = Set(regularItems.regularItems.map { $0.id })
        }
    }
}

#Preview {
    RegularCategoryListView()
}
