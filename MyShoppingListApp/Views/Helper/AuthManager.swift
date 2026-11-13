
import Foundation
import Combine
import FirebaseAuth

@MainActor
final class AuthManager: ObservableObject {
    
    @Published var user: User?
    @Published var errorMessage: String?
    
    init() {
        // 現在のログイン状態を取得
        self.user = Auth.auth().currentUser
    }
    
    /// 匿名ログイン
    func signInAnonymously() async {
        // すでにログインしていれば何もしない
        guard Auth.auth().currentUser == nil else {
            user = Auth.auth().currentUser
            return
        }
        
        do {
            let result = try await Auth.auth().signInAnonymously()
            
            user = result.user
            errorMessage = nil
            
            print("匿名ログイン成功")
            print("UID: \(result.user.uid)")
            print("匿名ユーザー: \(result.user.isAnonymous)")
            
        } catch {
            errorMessage = error.localizedDescription
            
            print("匿名ログイン失敗: \(error.localizedDescription)")
        }
    }
}
