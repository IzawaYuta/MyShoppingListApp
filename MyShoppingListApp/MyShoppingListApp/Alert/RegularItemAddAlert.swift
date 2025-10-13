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
                Button(action: {
                    onAdd()
                }) {
                    Text("追加")
//                        .padding()
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
            
            // 右側 完了ボタン
            Button(action: {
                // 完了処理
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

// 高さを保持するためのPreferenceKey

struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


#Preview {
    RegularItemAddAlert(newRegularItemName: .constant("あああ"), onAdd: {}, done: {})
}
