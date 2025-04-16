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
    
    // Dateをフォーマットするヘルパー
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        if deleteItemViewModel.isEmpty {
            Text("買ったものはありません")
        } else {
            List {
                ForEach(deleteItemViewModel) { list in
                    HStack {
                        Image(systemName:  "checkmark.square")
                            .foregroundStyle(.green)
                            .scaleEffect(1.2)
                        Text(list.name)
                        Spacer()
                        Text(dateFormatter.string(from: list.date))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            } // List
//            .scrollContentBackground(.hidden)
//            .background(
//                LinearGradient(gradient: Gradient(colors: [.pink, .green]), startPoint: .topLeading, endPoint: .bottomTrailing)
//            )
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
