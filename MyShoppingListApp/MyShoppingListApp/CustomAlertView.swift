//
//  CustomAlertView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/04/02.
//

import SwiftUI

struct CustomAlertView: View {
    var body: some View {
        ZStack {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill()
                    .frame(width: 200, height: 200)
                    .cornerRadius(20)
                    .foregroundColor(.gray)
                HStack {
                    Button("キャンセル", role: .cancel) {}
                        .foregroundColor(.black)
                    Button("追加") {}
                        .foregroundColor(.black)
                }
            }
            Circle()
                .frame(width: 100, height: 100)
                .foregroundColor(.white)
                .overlay(
                    Circle().stroke(Color.black, lineWidth: 2)
                )
                .offset(y: -100)
            
        }
    }
}

#Preview {
    CustomAlertView()
}
