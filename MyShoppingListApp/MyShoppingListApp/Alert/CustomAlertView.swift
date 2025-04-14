//
//  CustomAlertView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/04/02.
//

import SwiftUI

//struct CustomAlertView: View {
//    
//    @Binding var newText: String
//    @FocusState private var isFocused: Bool // TextFieldのフォーカス状態を管理
//    
//    var onAdd: () -> Void
//    var onCancel: () -> Void
//    
//    var body: some View {
//        
//        ZStack {
//            ZStack(alignment: .bottom) {
//                Rectangle()
//                    .fill()
//                    .frame(width: 220, height: 220)
//                    .cornerRadius(20)
//                    .foregroundColor(.white)
//                    .shadow(radius: 10)
//                Divider()
//                    .frame(width: 220, height: 1)
//                    .background(Color.gray)
//                    .offset(y: -45)
//                Rectangle()
//                    .frame(width: 0.5, height: 45) // 幅2、高さ45
//                    .foregroundColor(.gray)
//                    .offset(y: 0)
//                HStack {
//                    Button("キャンセル", role: .cancel) {
//                        onCancel()
//                    }
//                    .foregroundColor(.black)
//                    .offset(x: -16,y: 2)
//                    .padding()
//                    Button("追加") {
//                        onAdd()
//                    }
//                    .disabled(newText.isEmpty)
//                    .foregroundColor(newText.isEmpty ? .gray.opacity(0.5) : .black)
//                    .offset(x: -4,y: 2)
//                    .padding()
//                }
//            }
//            TextField("アイテム...", text: $newText)
//                .textFieldStyle(.roundedBorder)
//                .frame(width: 200)
//                .focused($isFocused) // フォーカス状態を設定
//            Text("カテゴリー")
//                .foregroundColor(Color.black.opacity(0.5))
//                .offset(y: -35)
//            ZStack {
//                Circle()
//                    .frame(width: 100, height: 100)
//                    .foregroundColor(.white)
//                    .shadow(radius: 7)
////                    .overlay(
////                        Circle().stroke(Color.black, lineWidth: 2)
////                    )
//                    .offset(y: -115)
//                Image("ShoppingList")
//                    .resizable()
//                    .frame(width: 50, height: 50)
//                    .offset(y: -115)
//            }
//        }
//        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
//                isFocused = true // 表示後にキーボードを表示
//            }
//        }
//    }
//}

struct CustomAlertView: View {
    
    @Binding var newText: String
    @FocusState private var isFocused: Bool // TextFieldのフォーカス状態を管理
    
    var onAdd: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(radius: 5)
                .frame(height: 190)
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Image(systemName: "cart")
                        .resizable()
                        .frame(width: 20, height: 18)
                    Text("カテゴリーを追加")
                        .font(.subheadline)
                }
                .padding(.horizontal)
                TextField("カテゴリー", text: $newText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .focused($isFocused) // フォーカス状態を設定
                HStack(spacing: 10) {
                    HStack(spacing: 3) {
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .frame(width: 13, height: 13)
                        Button("キャンセル", role: .cancel) {
                            onCancel()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(Color.black)
                    .cornerRadius(15)
                    Spacer()
                    HStack(spacing: 3) {
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .frame(width: 13, height: 13)
                        Button("追加") {
                            onAdd()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(newText.isEmpty ? Color.gray : Color.pink.opacity(0.5))
                    .foregroundColor(Color.black)
                    .cornerRadius(15)
                    .disabled(newText.isEmpty)
                }
                .padding(.horizontal)
            }
        }
        .padding(.horizontal)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                isFocused = true // 表示後にキーボードを表示
            }
        }
    }
}

#Preview {
    CustomAlertView(newText: .constant("プレビュー用の文字列"),
                        onAdd: {},
                        onCancel: {})
}
