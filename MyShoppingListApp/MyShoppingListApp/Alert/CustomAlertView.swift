//
//  CustomAlertView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/04/02.
//

import SwiftUI

struct CustomAlertView: View {
    
    @Binding var newText: String
    var onAdd: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
        
        ZStack {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill()
                    .frame(width: 220, height: 220)
                    .cornerRadius(20)
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                Divider()
                    .frame(width: 220, height: 1)
                    .background(Color.gray)
                    .offset(y: -45)
                Rectangle()
                    .frame(width: 0.5, height: 45) // 幅2、高さ45
                    .foregroundColor(.gray)
                    .offset(y: 0)
                HStack {
                    Button("キャンセル", role: .cancel) {
                        onCancel()
                    }
                    .foregroundColor(.black)
                    .offset(x: -16,y: 2)
                    .padding()
                    Button("追加") {
                        onAdd()
                    }
                    .disabled(newText.isEmpty)
                    .foregroundColor(newText.isEmpty ? .gray.opacity(0.5) : .black)
                    .offset(x: -4,y: 2)
                    .padding()
                }
            }
            TextField("アイテム...", text: $newText)
                .textFieldStyle(.roundedBorder)
                .frame(width: 200)
            Text("カテゴリー")
                .foregroundColor(Color.black.opacity(0.5))
                .offset(y: -35)
            ZStack {
                Circle()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .shadow(radius: 7)
//                    .overlay(
//                        Circle().stroke(Color.black, lineWidth: 2)
//                    )
                    .offset(y: -115)
                Image("ShoppingList")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .offset(y: -115)
            }
            
        }
    }
}

#Preview {
    CustomAlertView(newText: .constant("プレビュー用の文字列"),
                    onAdd: {},
                    onCancel: {})
}
