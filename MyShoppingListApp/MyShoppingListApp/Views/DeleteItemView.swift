//
//  DeleteItemView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/04/01.
//

import SwiftUI
import RealmSwift
import FirebaseAnalytics

class DeleteItemViewModel: Object, Identifiable {
    @Persisted var id: String = UUID().uuidString
    @Persisted var name = ""
    @Persisted var date = Date()
}

struct DeleteItemView: View {
    @ObservedResults(DeleteItemViewModel.self) var deleteItemViewModel
    @State private var showAlert = false
    @State private var timer: Timer? = nil
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    var body: some View {
        NavigationStack {
            if deleteItemViewModel.isEmpty {
                Text("買ったものはありません")
            } else {
                List {
                    ForEach(deleteItemViewModel.sorted(by: { $0.date > $1.date })) { list in
                        HStack {
                                Text(list.name)
                            Spacer()
                            Text(dateFormatter.string(from: list.date))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .contentShape(Rectangle())
                    }
                } // List
                .scrollContentBackground(.hidden)
                .background(
                    RadialGradient(gradient: Gradient(colors: [.brown.opacity(0.2), .indigo.opacity(0.2)]), center: .topLeading, startRadius: 10, endRadius: 900)
                )
                .onAppear {
                    Analytics.logEvent(AnalyticsEventScreenView, parameters: [
                        AnalyticsParameterScreenName: "DeleteListView",
                        AnalyticsParameterScreenClass: "DeleteListView"
                    ])
                }
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
                            Text("購入履歴は30日後に削除されます")
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
        let realm = try! Realm() // 現在の Realm インスタンスを取得
        let currentDate = Date()
        
        // Realm オブジェクトとしてフィルタリングする
        let expiredItems = deleteItemViewModel.filter { item in
            guard let realmItem = item.thaw() else { return false } // 必要なら thaw
            let timeInterval = currentDate.timeIntervalSince(realmItem.date)
            return timeInterval > (30 * 24 * 60 * 60)
        }
        
        // 削除処理
        try! realm.write {
            for item in expiredItems {
                if let thawedItem = item.thaw() { // thaw されたオブジェクトを削除
                    realm.delete(thawedItem)
                }
            }
        }
    }
}

#Preview {
    DeleteItemView()
}
