//
//  SuccessAlertView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/04/02.
//

import SwiftUI

struct SuccessAlertView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(colors: [.pink, .yellow], startPoint: .topTrailing, endPoint: .bottomLeading))
                .frame(width: 100, height: 100)
//            Image("checkmark")
//                .resizable() // 画像をリサイズ可能にする
//                .frame(width: 80, height: 80) // サイズを指定
//                .offset(y: -3)
            Image(systemName: "checkmark")
                .font(.system(size: 50))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    SuccessAlertView()
}
