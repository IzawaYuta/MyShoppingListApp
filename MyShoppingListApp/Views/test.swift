//
//  test.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2026/11/05.
//

import SwiftUI

struct test: View {
    var body: some View {
        Text("自")
            .padding()
            .foregroundColor(.black)
            .background(RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.5))
            )
    }
}

#Preview {
    test()
}
