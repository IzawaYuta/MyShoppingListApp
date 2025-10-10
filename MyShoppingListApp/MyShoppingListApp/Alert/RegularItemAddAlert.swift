//
//  RegularItemAddAlert.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/10/09.
//

import SwiftUI

struct RegularItemAddAlert: View {
    
    @Binding var newRegularItemName: String
    @FocusState private var isFocused: Bool // TextFieldのフォーカス状態を管理
    
    var onAdd: () -> Void
        
    var body: some View {
        HStack {
            TextField("アイテム", text: $newRegularItemName)
            //                            .padding()
            //                            .foregroundColor(Color.black)
                .focused($isFocused) // フォーカス状態を設定
            Button(action: {
//                addItem()
//                showButton = false
                onAdd()
            }) {
//                if colorScheme == .dark {
//                    Text("追加")
//                        .padding()
//                        .foregroundColor(newRegularItemName.isEmpty ? Color.white : Color.black.opacity(0.5))
//                        .cornerRadius(8)
//                } else {
                    Text("追加")
                        .padding()
                        .foregroundColor(newRegularItemName.isEmpty ? Color.gray : Color.black)
                        .cornerRadius(8)
//                }
            }
            .disabled(newRegularItemName.isEmpty)
        }
        .padding(.horizontal)
        .background(.gray.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black, lineWidth: 1)
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                isFocused = true // 表示後にキーボードを表示
            }
        }
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

#Preview {
    RegularItemAddAlert(newRegularItemName: .constant("あああ"), onAdd: {})
}
