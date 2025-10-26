//
//  CustomAlertView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/04/02.
//

import SwiftUI

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
                .frame(height: 180)
            VStack(alignment: .center, spacing: 13) {
                HStack {
                    Image(systemName: "cart")
                        .resizable()
                        .frame(width: 20, height: 18)
                        .foregroundColor(Color.black)
                    Text("カテゴリーを追加")
                        .font(.subheadline)
                        .foregroundColor(Color.black)
                }
                .padding(.horizontal)
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                    TextField("カテゴリー", text: $newText)
                        .frame(height: 50) // 高さを指定
                        .padding(.horizontal)
                        .focused($isFocused) // フォーカス状態を設定
                        .onSubmit {
                            onCancel()
                        }
                        .onChange(of: newText) { newValue in
                            // 空白を除去
                            let filtered = newValue.replacingOccurrences(of: " ", with: "")
                                .replacingOccurrences(of: "　", with: "") // 全角スペースも
                            if filtered != newValue {
                                newText = filtered
                            }
                        }
                }
                .padding(.horizontal)
                HStack(spacing: 10) {
                    HStack(spacing: -3) {
                        Image("xmark")
                            .resizable()
                            .frame(width: 25, height: 25)
                        Text("キャンセル")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(Color.black)
                    .cornerRadius(15)
                    .onTapGesture {
                        onCancel()
                    }
                    Spacer()
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark")
                            .resizable()
                            .frame(width: 10, height: 10)
                        Text("追加")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(newText.isEmpty ? Color.gray.opacity(0.5) : Color.blue.opacity(0.5))
                    .foregroundColor(Color.black)
                    .cornerRadius(15)
                    .onTapGesture { // ボタンの判定範囲を広げる
                        if !newText.isEmpty {
                            onAdd()
                        }
                    }
                    .disabled(newText.isEmpty)
                }
                .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity)
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
