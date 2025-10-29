//
//  NoticeView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/10/29.
//

import SwiftUI

struct NoticeView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("お知らせ")
                .font(.system(size: 20))
            Text("Webサービス by Yahoo! JAPAN （https://developer.yahoo.co.jp/sitemap/）")
        }
    }
}

#Preview {
    NoticeView()
}
