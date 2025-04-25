//
//  ShareView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/04/09.
//

import SwiftUI
import RealmSwift

struct ShareView: View {
    
    @ObservedResults(CategoryListModel.self) var categoryListModel
    @State private var nickname: String = "" // ローカルの状態で保持
    @State var select = false
//    @ObservedResults(Nickname.self) private var nicknames // Realmのデータを監視
    
    @State private var tutorialStep: Int = 0
    @State private var showTutorial: Bool = true
    @State private var ok = false
    @State private var back = false
    
    private func navigateToSettings() {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first
        keyWindow?.rootViewController = UIHostingController(rootView: SettingView())
        keyWindow?.makeKeyAndVisible()
    }
    
    var body: some View {
//        if nicknames.first?.nickname?.isEmpty ?? true {
//            Text("共有をする場合は、\nニックネームを設定してください")
//        } else {
//            if showTutorial {
//                Spacer()
//                    if tutorialStep == 0 {
//                        Text("共有を有効にすると、") +
//                        Text("共同編集")
//                            .foregroundColor(.red)
//                            .bold() +
//                        Text("が有効になります。")
//                    } else if tutorialStep == 1 {
//                        Text("共有をONにする場合、必ずニックネームを設定してください。\n相手のリストに表示されます。")
//                    } else if tutorialStep == 2 {
//                        Text("相手のデバイスにアプリがインストールされていますか？\nインストールされていない場合、共有機能は正しく動作しません。")
//                    }
//                Spacer()
//                    HStack(spacing: 100) {
//                        Button(action: {
//                            back.toggle()
//                            tutorialStep -= 1
//                        }) {
//                            Image(systemName: "arrow.left")
//                        }
//                        .font(.system(size: 40))
//                        .disabled(tutorialStep == 0)
//                        Button(action: {
//                            ok.toggle()
//                            tutorialStep += 1
//                            if tutorialStep > 2 {
//                                showTutorial = false
//                            }
//                        }) {
//                            Image(systemName: "checkmark")
//                        }
//                        .font(.system(size: 40))
//                        .foregroundColor(Color.pink.opacity(0.9))
//                    }
//                    .padding(.top, -300)
//            } else {
                VStack(alignment: .trailing) {
                    HStack {
                        ShareLink(item: "あ")
                        Button(action: {
                        }) {
                            Text("編集")
                        }
                        Button(action: {
                            showTutorial = true
                        }) {
                            Image(systemName: "info.circle")
                        }
                    }
                    .padding(.horizontal, 20)
                        List {
                            ForEach(categoryListModel) { list in
                                HStack {
                                    Text(list.name)
                                    Spacer()
                                    Image(systemName: select ? "circle.fill" : "circle")
                                }
                                .onTapGesture {
                                    select.toggle()
                                }
                            }
                        } // List
                        .listStyle(.inset)
                    }
                .padding(.horizontal)
            }
        }
//    }
//}

#Preview {
    ShareView()
}

//struct TutorialBubble: View {
//    var text: String
//    
//    var body: some View {
//        VStack {
//            Text(text)
//                .font(.body)
//                .padding()
//                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
//                .shadow(radius: 5)
//        }
//        .frame(maxWidth: 500)
//    }
//}
