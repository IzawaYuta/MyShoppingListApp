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
                .fill(LinearGradient(colors: [.indigo, .cyan], startPoint: .topTrailing, endPoint: .bottomLeading))
                .shadow(color: .white, radius: 10)
                .frame(width: 100, height: 100)
            Image(systemName: "checkmark")
                .font(.system(size: 30))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    SuccessAlertView()
}
