//
//  SettingView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/03/28.
//

import SwiftUI
import RealmSwift
import StoreKit

class Nickname: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var nickname: String?
}

struct SettingView: View {
    
    @AppStorage(wrappedValue: 0, "appearanceMode") var appearanceMode
    @Environment(\.requestReview) var requestReview
    @State private var nickname = ""
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    
    var body: some View {
        NavigationStack {
            List {
                Section("プロフィール") {
                        HStack {
                            Image(systemName: "person")
                                .font(.system(size: 30))
                            TextField("ニックネーム", text: $nickname)
                                .onChange(of: nickname) { newValue in
                                    saveNickname(newValue)
                                }
                                .font(.system(size: 20))
                        }
                    .frame(height: 60) // 縦幅を80ポイントに設定
                }
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
                        .pickerStyle(.automatic)
                        .frame(height: 20) // 縦幅を80ポイントに設定
                    }
                    NavigationLink(destination: ShareView()) {
                        Text("共有設定")
                    }
                }
                Section("サポート") {
                    NavigationLink(destination: ContactUsView()) {
                        Text("お問い合わせ")
                    }
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
//                    Text("アプリを共有")
////                    Link("アプリを共有", destination: URL(string: "")!)
                }
            }
            .listStyle(.grouped)
            .onAppear {
                loadNickname()
            }
        }
    }
    
    private func saveNickname(_ newNickname: String) {
        let realm = try! Realm()
        if let existingNickname = realm.objects(Nickname.self).first {
            try! realm.write {
                existingNickname.nickname = newNickname
            }
        } else {
            let nicknameObject = Nickname()
            nicknameObject.nickname = newNickname
            try! realm.write {
                realm.add(nicknameObject)
            }
        }
    }
    
    // Realmからニックネームをロード
    private func loadNickname() {
        let realm = try! Realm()
        if let existingNickname = realm.objects(Nickname.self).first {
            nickname = existingNickname.nickname ?? ""
        }
    }
}

#Preview {
    SettingView()
}
