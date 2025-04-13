//
//  RegularView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/03/31.
//

import RealmSwift
import SwiftUI

class RegularItem: Object, Identifiable {
    @Persisted(primaryKey: true) var id: UUID = UUID() // プライマリキーを明示
    @Persisted var name: String = ""
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

// MARK: RegularCategoryListView
struct RegularCategoryListView: View {
    @ObservedResults(CategoryListModel.self) var categoryListModel
    
    var body: some View {
        NavigationStack {
            VStack {
                // categoryListModelが空の場合
                if categoryListModel.isEmpty {
                    Text("カテゴリーを追加しましょう！")
                        .foregroundColor(.gray) // 文字色を指定することも可能
                } else {
                    // categoryListModelにデータがある場合
                    List {
                        ForEach(categoryListModel) { category in
                            NavigationLink(destination: RegularListView(categoryListModel: category)) {
                                Text(category.name)
                            }
                        }
                    }
                }
            }
            .navigationTitle("定期品リスト")
        }
    }
}

// MARK: RegularListView
struct RegularListView: View {
    @ObservedRealmObject var categoryListModel: CategoryListModel
    @State private var isAddingItem = false
    @State private var newRegularItemName = ""
    @State private var selectedItems = Set<String>() // 選択されたアイテムを追跡
    @State private var selectedAllItems = false
    @State private var isDone = false
    
    
    var body: some View {
        
        let regularItemsArray = Array(categoryListModel.regularItems)
        
        ZStack(alignment: .bottom) {
            List {
                ForEach(regularItemsArray, id: \.id) { list in
                    HStack {
                        Image(systemName: selectedItems.contains(list.id.uuidString) ? "circle.inset.filled" : "circle")
                            .scaleEffect(selectedItems.contains(list.id.uuidString) ? 1.3 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.2), value: selectedItems)
                        Text(list.name)
                        
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        
                        toggleSelection(for: list)
                    }
                }
                .onDelete(perform: deleteItem)
            }
            HStack {
                TextField("入力してください", text: $newRegularItemName)
                    .padding()
                Button(action: {
                    addItem()
                }) {
                    Text("追加")
                        .padding()
                }
                .disabled(newRegularItemName.isEmpty)
            }
            .background(Color.white)
            .frame(height: 80)
            .cornerRadius(10)
            .shadow(radius: 3)
            .padding()
        }
        .listStyle(PlainListStyle())
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    if selectedItems == [] {
                    } else {
                        Button(action: {
                            saveSelectedItems()
                            isDone = true
                        }) {
                            Image(systemName: "arrow.up")
                        }
                        .sheet(isPresented: $isDone) {
                            SuccessAlertView()
                                .presentationDetents([.fraction(0.3)])
                                .presentationBackground(.clear)
                                .transition(.move(edge: .bottom))
                        }
                        .onChange(of: isDone) { newValue in
                            if newValue {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    withAnimation {
                                        isDone = false
                                    }
                                }
                            }
                        }
                    }
                    Button(action: {
                        selectedAllItems.toggle()
                        selectAllItems()
                    }) {
                        Image(systemName: selectedItems.count == (categoryListModel.regularItems.count) ? "xmark.circle" : "checkmark.circle")
                    }
                }
            }
        }
        .navigationTitle("\(categoryListModel.name) の定期品")
    }
    
    // 定期品追加メソッド
    private func addItem() {
        guard !newRegularItemName.isEmpty else { return }
        let newItem = RegularItem(name: newRegularItemName) // データを渡して初期化
        let realm = try! Realm()
        try! realm.write {
            $categoryListModel.regularItems.append(newItem) // トランザクション内で追加
        }
        newRegularItemName = ""
        print("追加後のRegularItem: \(RegularItem())") // 正しいアイテムを表示
        print("追加後のcategory: \($categoryListModel.regularItems)") // 正しいリストを表示
    }
    
    // 定期品削除メソッド
    private func deleteItem(at offsets: IndexSet) {
        let realm = try! Realm()
        try! realm.write {
            $categoryListModel.regularItems.remove(atOffsets: offsets) // 同様に自動トランザクション
        }
        print("削除後のRegularItem♥️♥️\(RegularItem())")
        print("削除後のcategory♥️\($categoryListModel.regularItems)")
    }
    
    // チェック切り替え
    private func toggleSelection(for item: RegularItem) {
        if selectedItems.contains(item.id.uuidString) {
            selectedItems.remove(item.id.uuidString)
        } else {
            selectedItems.insert(item.id.uuidString)
        }
    }
    
    // リストの全選択
    private func selectAllItems() {
        //        guard let regularItems = categoryListModel else { return }
        let regularItems = categoryListModel
        if selectedItems.count == regularItems.regularItems.count {
            // 全選択されている場合、選択解除
            selectedItems.removeAll()
        } else {
            // 全選択されていない場合、全て選択
            selectedItems = Set(regularItems.regularItems.map { $0.id.uuidString })
        }
    }
    
    private func saveSelectedItems() {
        let realm = try! Realm()
        try! realm.write {
            let selectedRegularItems = categoryListModel.regularItems.filter { selectedItems.contains($0.id.uuidString) }
            
            for regularItem in selectedRegularItems {
                let item = Item()
                item.name = regularItem.name
                
                $categoryListModel.items.append(item) // Listに追加 (realm.writeブロック内で行う)
                realm.add(item) // Realmに明示的に保存
            }
        }
    }
}

#Preview {
    RegularCategoryListView()
}
