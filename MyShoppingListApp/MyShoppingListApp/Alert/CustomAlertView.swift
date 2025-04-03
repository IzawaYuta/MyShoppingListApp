//
//  CustomAlertView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/04/02.
//

import SwiftUI

struct CustomAlertView: View {
    @State var newText = ""
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
                    .frame(width: 220, height: 2)
                    .background(Color.gray)
                    .offset(y: -45)
                // 縦の赤い線（Rectangle の中央）
                Rectangle()
                    .frame(width: 2, height: 45) // 幅2、高さ45
                    .foregroundColor(.gray)
                    .offset(y: 0) // HStack の高さの半分上にずらす
                HStack {
                    Button("キャンセル", role: .cancel) {}
                        .foregroundColor(.black)
                        .padding()
                    Button("追加") {}
                        .foregroundColor(.black)
                        .padding()
                }
            }
            TextField("テキスト", text: $newText)
                .textFieldStyle(.roundedBorder)
                .frame(width: 200)
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
    CustomAlertView()
}
