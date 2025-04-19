//
//  SettingView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/03/28.
//

import SwiftUI
import StoreKit

struct SettingView: View {
    
    @AppStorage(wrappedValue: 0, "appearanceMode") var appearanceMode
    @Environment(\.requestReview) var requestReview
    
    var body: some View {
        NavigationStack {
            List {
                Section("設定") {
                    HStack {
                        Text("外観モード")
                        Picker("", selection: $appearanceMode) {
                            Text("システム")
                                .tag(0)
                            Text("ライト")
                                .tag(1)
                            Text("ダーク")
                                .tag(2)
                        }
                        .pickerStyle(.menu)
                    }
                    NavigationLink(destination: ShareView()) {
                        Text("共有設定")
                    }
                }
                Section("サポート") {
                    Link("リンク", destination: URL(string: "https://www.google.com")!)

                    Text("お問い合わせ")
                    Text("プライバシーポリシー")
                    HStack {
                        Text("アプリバージョン")
                        Spacer()
                        Text("v1.0.0 (1)")
                            .foregroundColor(Color.gray)
                    }
                }
                Section("評価") {
                    Button("レビュー") {
                        requestReview()
                    }
                    .foregroundColor(Color.black)
                }
            }
            .listStyle(.grouped)
        }
    }
}

#Preview {
    SettingView()
}
