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
    @State private var timer: Timer? = nil
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
                                Text(list.name)
                                    .font(.headline)
                            Spacer()
                            Text(dateFormatter.string(from: list.date))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .contentShape(Rectangle())
                    }
                } // List
                .navigationTitle("購入履歴")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            showAlert = true
                        }) {
                            Image(systemName: "info.circle")
                        }
                        .alert("", isPresented: $showAlert) {
                            Button("完了", role: .cancel) {}
                        } message: {
                            Text("購入履歴は30日後に削除されます。")
                        }

                    }
                }
                .onAppear {
                    deleteExpiredItems()
                    // 1時間ごとに削除チェック
                    timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                        deleteExpiredItems()
                    }
                }
                .onDisappear {
                    timer?.invalidate() // タイマーを停止
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
}

#Preview {
    DeleteItemView()
}
