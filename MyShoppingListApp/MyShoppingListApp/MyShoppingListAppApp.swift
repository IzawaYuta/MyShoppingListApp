//
//  MyShoppingListAppApp.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/03/21.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//#if !DEBUG || !targetEnvironment(simulator)
        FirebaseApp.configure()
//#endif
        return true
    }
}

@main
struct MyShoppingListAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // 画面が表示されたときに匿名ログインを自動的に実行
                    Auth.auth().signInAnonymously { authResult, error in
                        if let error = error {
                            print("匿名ログインエラー: \(error.localizedDescription)")
                        } else if let user = authResult?.user {
                            // ログイン成功した場合、ログイン状態を更新
                            print("匿名ログイン成功: UID = \(user.uid)")
                        }
                    }
                }
        }
    }
}
