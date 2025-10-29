//
//  RegularItemAddAlert.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/10/09.
//

import SwiftUI

struct RegularItemAddAlert: View {
    
    @Binding var newRegularItemName: String
    @FocusState private var isFocused: Bool
    
    var onAdd: () -> Void
    var done: () -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            // 左側 HStack
            HStack {
                TextField("アイテム", text: $newRegularItemName)
                    .focused($isFocused)
                    .onSubmit {
                        done()
                        newRegularItemName = ""
                    }
                    .onChange(of: newRegularItemName) { newValue in
                        // 空白を除去
                        let filtered = newValue.replacingOccurrences(of: " ", with: "")
                            .replacingOccurrences(of: "　", with: "") // 全角スペースも
                        if filtered != newValue {
                            newRegularItemName = filtered
                        }
                    }
                Button(action: {
                    onAdd()
                }) {
                    Text("追加")
                        .foregroundColor(newRegularItemName.isEmpty ? Color.gray : Color.black)
                        .cornerRadius(8)
                }
                .disabled(newRegularItemName.isEmpty)
            }
            .padding(.horizontal)
            .frame(maxHeight: .infinity) // 高さを親に合わせる
            .background(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black, lineWidth: 1)
            )
            .cornerRadius(8)
            .layoutPriority(1)
            
            Button(action: {
                done()
                newRegularItemName = ""
            }) {
                Text("閉じる")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: UIScreen.main.bounds.width * 0.2)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.gray)
            )
        }
        .frame(height: 50) // 必要に応じて固定 or 自動調整
        .padding(.horizontal)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                isFocused = true // 表示後にキーボードを表示
            }
        }
    }
}

#Preview {
    RegularItemAddAlert(newRegularItemName: .constant("あああ"), onAdd: {}, done: {})
}
