//
//  ShareView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/04/09.
//

import SwiftUI
import RealmSwift

enum NavigationTarget: Hashable {
    case setting
}

struct ShareView: View {
    
    @ObservedResults(CategoryListModel.self) var categoryListModel
    @State private var isOn = false
    @State private var isEdit = false
    
    @State private var nickname: String = "" // ローカルの状態で保持
    @ObservedResults(Nickname.self) private var nicknames // Realmのデータを監視
    
    private func navigateToSettings() {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first
        keyWindow?.rootViewController = UIHostingController(rootView: SettingView())
        keyWindow?.makeKeyAndVisible()
    }
    
    var body: some View {
        if nicknames.first?.nickname?.isEmpty ?? true {
            Text("共有をする場合は、\nニックネームを設定してください")
        } else {
            VStack(alignment: .trailing) {
                Button(action: {
                    isEdit.toggle()
                }) {
                    Text("編集")
                }
                .padding(.horizontal, 40)
                VStack(spacing: 50) {
                    ZStack {
                        // 背景のRoundedRectangle
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.5), radius: 5)
                            .frame(width: 420, height: 140) // 高さを少し広げる
                            .padding()
                        
                        // 説明文テキスト
                        VStack(alignment: .leading, spacing: 10) { // 縦方向に余白を追加
                            Text("共有をONにすると共同編集が有効になります。")
                                .font(.system(size: 14, weight: .semibold)) // 少し強調
                            Text("共有を有効にする場合は、ニックネームの設定が必要です。")
                                .font(.system(size: 12))
                            Text("共有する前に、相手がアプリをインストールしていることを確認してください。")
                                .font(.system(size: 12))
                            Text("共有先のデバイスにアプリがインストールされていないと、正常にリストが共有されません。")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.black.opacity(0.8)) // テキストカラー
                        .padding(.horizontal, 20) // 左右の余白を追加
                        .padding(.vertical, 10) // 上下の余白を追加
                        .frame(maxWidth: .infinity, alignment: .leading) // 左揃え
                    }
                    List {
                        ForEach(categoryListModel) { list in
                            HStack {
                                Text(list.name)
                                Spacer()
                                if isEdit {
                                    Text("編集中")
                                }
                                if isOn {
                                    Text("共有中")
                                }
                            }
                        }
                    } // List
                    .listStyle(.inset)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func shareList() {
        
    }
}

#Preview {
    ShareView()
}


//VStack(spacing: 15) {
//    ForEach(categoryListModel) { list in
//        ZStack {
//            RoundedRectangle(cornerRadius: 10)
//                .foregroundColor(.gray)
//                .frame(width: 350, height: 50)
//            HStack {
//                Text(list.name)
//                Spacer()
//                Toggle("トグル", isOn: Binding(
//                    get: { list.isOn },
//                    set: { newValue in
//                        if let realm = list.realm {
//                            try? realm.write {
//                                list.isOn = newValue
//                            }
//                        }
//                    }
//                ))
//                .labelsHidden()
//            }
//            .padding(.horizontal)
//        }
//    }
//}
//.padding()
//}
//}
