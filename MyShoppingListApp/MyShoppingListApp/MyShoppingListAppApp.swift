//
//  MyShoppingListAppApp.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/03/21.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import RealmSwift

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
    
    init() {
        // Realm マイグレーション設定
        let config = Realm.Configuration(
            schemaVersion: 3, // ← モデルを変更したらここを +1 する
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 2 {
                    // 必要に応じてマイグレーション処理を書く
                    // 例: migration.renameProperty(onType: "OldModel", from: "oldName", to: "newName")
                }
            }
        )
        
        // デフォルト設定を上書き
        Realm.Configuration.defaultConfiguration = config
        
        // ✅ Realmのファイルパス確認（デバッグ用）
        print("📂 Realm file path: \(Realm.Configuration.defaultConfiguration.fileURL!.path)")
    }
    
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
