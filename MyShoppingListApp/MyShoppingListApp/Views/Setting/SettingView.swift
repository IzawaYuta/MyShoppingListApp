//
//  SettingView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/03/28.
//

import SwiftUI
import RealmSwift
import StoreKit
import FirebaseAnalytics

//class Nickname: Object, Identifiable {
//    @Persisted(primaryKey: true) var id: String = UUID().uuidString
////    @Persisted var nickname: String?
//}

struct SettingView: View {
    
    @AppStorage(wrappedValue: 0, "appearanceMode") var appearanceMode
    @Environment(\.requestReview) var requestReview
//    @State private var nickname = ""
    @State private var showMailSheet = false
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    
    var body: some View {
        NavigationStack {
            List {
//                Section("プロフィール") {
//                        HStack {
//                            Image(systemName: "person")
//                                .font(.system(size: 30))
//                            TextField("ニックネーム", text: $nickname)
//                                .onChange(of: nickname) { newValue in
//                                    saveNickname(newValue)
//                                }
//                                .font(.system(size: 20))
//                        }
//                    .frame(height: 60) // 縦幅を80ポイントに設定
//                }
                Section("") {
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
//                    NavigationLink(destination: ShareView()) {
//                        Text("共有設定")
//                    }
                }
                Section("") {
//                    NavigationLink(destination: ContactUsView()) {
//                        Text("お問い合わせ")
//                    }
//                    Button(action: {
//                        showMailSheet.toggle()
//                    }) {
//                        Text("あ")
//                    }
//                    .sheet(isPresented: $showMailSheet) {
//                        MailView(isShowing: $showMailSheet, name: "", email: "", message: "")
                    //                    }
                    Link("お問い合わせ", destination: URL(string: "https://shoppinglistsupport.wixsite.com/my-site-1")!)
                        .foregroundColor(Color.primary)
                    
                    Link("プライバシーポリシー", destination: URL(string: "https://ten-emery-9f5.notion.site/1dc95f7f1d1080ceb0eae74b2ada2c5a")!)
                        .foregroundColor(Color.primary)
                    HStack {
                        Text("アプリバージョン")
                        Spacer()
                        Text("\(appVersion)")
                            .foregroundColor(Color.gray)
                        Text("(\(buildNumber))")
                            .foregroundColor(Color.gray)
                    }
                }
                Section("") {
//                    Button("レビュー") {
//                        requestReview()
//                    }
//                    .foregroundColor(Color.primary)
                    Link("アプリを共有", destination: URL(string: "https://apps.apple.com/jp/app/%E3%82%AB%E3%82%B4%E3%82%8A%E3%81%99%E3%81%A8/id6745005617?itscg=30200&itsct=apps_box_link&mttnsubad=6745005617")!)
                        .foregroundColor(Color.primary)
                }
            }
            .listStyle(.grouped)
            .onAppear {
                Analytics.logEvent(AnalyticsEventScreenView, parameters: [
                    AnalyticsParameterScreenName: "SettingView",
                    AnalyticsParameterScreenClass: "SettingView"
                ])
            }
//            .onAppear {
//                loadNickname()
//            }
        }
    }
    
//    private func saveNickname(_ newNickname: String) {
//        let realm = try! Realm()
//        if let existingNickname = realm.objects(Nickname.self).first {
//            try! realm.write {
//                existingNickname.nickname = newNickname
//            }
//        } else {
//            let nicknameObject = Nickname()
//            nicknameObject.nickname = newNickname
//            try! realm.write {
//                realm.add(nicknameObject)
//            }
//        }
//    }
    
//    // Realmからニックネームをロード
//    private func loadNickname() {
//        let realm = try! Realm()
//        if let existingNickname = realm.objects(Nickname.self).first {
//            nickname = existingNickname.nickname ?? ""
//        }
//    }
}

#Preview {
    SettingView()
}
