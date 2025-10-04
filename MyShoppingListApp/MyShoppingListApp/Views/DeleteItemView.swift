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
    
    private var grouped: [Date: [DeleteItemViewModel]] {
        Dictionary(grouping: deleteItemViewModel) { item in
            Calendar.current.startOfDay(for: item.date)
        }
    }
    
    var body: some View {
        NavigationStack {
            if deleteItemViewModel.isEmpty {
                Text("買ったものはありません")
            } else {
                List {
                    ForEach(grouped.keys.sorted(by: >), id: \.self) { date in
                        Section {
                            ForEach(grouped[date]!) { list in
                                HStack {
                                    Text(list.name)
                                    Spacer()
                                    Text(dateFormatter.string(from: list.date))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .contentShape(Rectangle())
                            }
                        } header: {
                            if date == grouped.keys.sorted(by: >).first {
                                HStack {
                                    Spacer()
                                    Text("履歴は30日後に削除されます")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.red.opacity(0.2), .clear, .red.opacity(0.1)]),
                                //                                    gradient: Gradient(colors: [.clear, .black.opacity(0.5), .clear]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .ignoresSafeArea()
                )
                .onAppear {
                    Analytics.logEvent(AnalyticsEventScreenView, parameters: [
                        AnalyticsParameterScreenName: "DeleteListView",
                        AnalyticsParameterScreenClass: "DeleteListView"
                    ])
                }
                .navigationTitle("購入履歴")
                .toolbarTitleDisplayMode(.inlineLarge)
                //                .toolbar {
                //                    ToolbarItem(placement: .topBarTrailing) {
                //                        Button(action: {
                //                            showAlert = true
                //                        }) {
                //                            Image(systemName: "info.circle")
                //                        }
                //                        .alert("", isPresented: $showAlert) {
                //                            Button("完了", role: .cancel) {}
                //                        } message: {
                //                            Text("購入履歴は30日後に削除されます")
                //                        }
                //
                //                    }
                //                }
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
