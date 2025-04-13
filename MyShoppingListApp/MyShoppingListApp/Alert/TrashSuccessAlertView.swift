//
//  TrashSuccessAlertView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/04/13.
//

import SwiftUI

struct TrashSuccessAlertView: View {
    var body: some View {
        ZStack {
            Circle()
//                .fill((colors: [.red, .yellow], startPoint: .bottomLeading, endPoint: .topTrailing))
                .fill(RadialGradient(colors: [.pink, .yellow], center: .topLeading, startRadius: 0, endRadius: 160))
                .shadow(radius: 5)
                .frame(width: 100, height: 100)
            Image(systemName: "trash")
                .foregroundColor(.white)
                .font(.system(size: 30))
        }
    }
}

#Preview {
    TrashSuccessAlertView()
}
