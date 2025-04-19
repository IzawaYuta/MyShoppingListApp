//
//  DeleteItemView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/04/01.
//

import SwiftUI
import RealmSwift

class DeleteItemViewModel: Object, Identifiable {
    @Persisted var id: String = UUID().uuidString
    @Persisted var name = ""
    @Persisted var date = Date()
}

struct DeleteItemView: View {
    @ObservedResults(DeleteItemViewModel.self) var deleteItemViewModel
    @State private var showAlert = false
//    let categoryListModel = CategoryListModel()
//    @State private var selectedItems = Set<String>() // 選択されたアイテムを追跡
    
    // Dateをフォーマットするヘルパー
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        NavigationStack {
            if deleteItemViewModel.isEmpty {
                Text("買ったものはありません")
            } else {
                List {
                    ForEach(deleteItemViewModel) { list in
                        HStack {
//                            Image(systemName: selectedItems.contains(list.id) ? "circle.inset.filled" : "circle")
                            Text(list.name)
                            Spacer()
                            Text(dateFormatter.string(from: list.date))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .contentShape(Rectangle())
//                        .onTapGesture {
//                            toggleSelection(for: list)
//                        }
                    }
                } // List
                //            .scrollContentBackground(.hidden)
                //            .background(
                //                LinearGradient(gradient: Gradient(colors: [.pink, .green]), startPoint: .topLeading, endPoint: .bottomTrailing)
                //            )
                .navigationTitle("購入済みアイテム")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
//                        if selectedItems == [] {
//                        } else {
//                            Button(action: {
//                                saveSelectedItems()
//                            }) {
//                                Image(systemName: "arrow.up")
//                            }
//                        }
                        Button(action: {
                            showAlert = true
                        }) {
                            Image(systemName: "info.circle")
                        }
                        .alert("", isPresented: $showAlert) {
                            Button("完了", role: .cancel) {}
                        } message: {
                            Text("購入済みアイテムは30日後に削除されます。")
                        }

                    }
                }
            }
        }
    }
    
    private func deleteExpiredItems() {
        let realm = try! Realm()
        let currentDate = Date()
        let expiredItems = deleteItemViewModel.filter {
            let timeInterval = currentDate.timeIntervalSince($0.date)
            return timeInterval > (24 * 60 * 60)
        }
        try! realm.write {
            for item in expiredItems {
                realm.delete(item)
            }
        }
    }
//    private func toggleSelection(for item: DeleteItemViewModel) {
//        if selectedItems.contains(item.id) {
//            selectedItems.remove(item.id)
//        } else {
//            selectedItems.insert(item.id)
//        }
//    }
//    private func saveSelectedItems() {
//        let realm = try! Realm()
//        try! realm.write {
//            let selectedRegularItems = deleteItemViewModel.filter { selectedItems.contains($0.id) }
//            
//            for regularItem in selectedRegularItems {
//                let item = Item()
//                item.name = regularItem.name
//                
//                categoryListModel.items.append(item) // Listに追加 (realm.writeブロック内で行う)
//                realm.add(item) // Realmに明示的に保存
//            }
//        }
//    }
}

#Preview {
    DeleteItemView()
}
