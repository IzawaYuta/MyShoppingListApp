//
//  MailView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/04/22.
//

import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    var name: String
    var email: String
    var message: String
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView
        
        init(parent: MailView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.isShowing = false
            controller.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = context.coordinator
        
        // 下書き画面を開くだけにする（宛先や件名も必要に応じて設定）
        mailComposeVC.setToRecipients(["i.developer.y@gmail.com"]) // 任意の宛先
        mailComposeVC.setSubject("お問い合わせ") // 任意の件名
        // mailComposeVC.setMessageBody("", isHTML: false) // 本文は空白
        
        return mailComposeVC
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}

//#Preview {
//    MailView()
//}
