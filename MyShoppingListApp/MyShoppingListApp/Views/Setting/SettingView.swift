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
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    
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
                        Text("\(appVersion)")
                            .foregroundColor(Color.gray)
                        Text("(\(buildNumber))")
                            .foregroundColor(Color.gray)
                    }
                }
                Section("評価") {
                    Button("レビュー") {
                        requestReview()
                    }
                    .foregroundColor(Color.primary)
                }
            }
            .listStyle(.grouped)
        }
    }
}

#Preview {
    SettingView()
}
