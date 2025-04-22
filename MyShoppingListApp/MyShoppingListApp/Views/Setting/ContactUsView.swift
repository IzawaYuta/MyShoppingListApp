//
//  ContactUsView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/04/21.
//

import SwiftUI
import MessageUI

struct ContactUsView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var showMailSheet = false
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("お名前")) {
                    TextField("お名前を入力してください", text: $name)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled(true)
                }
                
                Section(header: Text("メールアドレス")) {
                    TextField("メールアドレスを入力してください", text: $email)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.none)
                }
                
                Section(header: Text("お問い合わせ内容")) {
                    TextEditor(text: $message)
                        .frame(height: 150)
                }
                
                Section {
                    Button(action: {
                        if isValidInput() {
                            print("Message: \(message)") // Debug用
                            showMailSheet.toggle()
                        } else {
                            showAlert.toggle()
                        }
                    }) {
                        Text("送信")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
//            .navigationTitle("お問い合わせ")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("入力エラー"), message: Text("全てのフィールドを正しく入力してください。"), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showMailSheet) {
                MailView(isShowing: $showMailSheet, name: name, email: email, message: message)
            }
        }
    }
    
    private func isValidInput() -> Bool {
        return !name.isEmpty && !email.isEmpty && !message.isEmpty && email.contains("@")
    }
}

#Preview {
    ContactUsView()
}
import SwiftUI
import MessageUI

//struct MailView: UIViewControllerRepresentable {
//    @Binding var isShowing: Bool
//    var name: String
//    var email: String
//    var message: String
//    
//    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
//        var parent: MailView
//        
//        init(parent: MailView) {
//            self.parent = parent
//        }
//        
//        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
//            parent.isShowing = false
//            controller.dismiss(animated: true)
//        }
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(parent: self)
//    }
//    
//    func makeUIViewController(context: Context) -> MFMailComposeViewController {
//        let mailComposeVC = MFMailComposeViewController()
//        mailComposeVC.mailComposeDelegate = context.coordinator
//        mailComposeVC.setToRecipients(["yutaizw2512@icloud.com"])
//        mailComposeVC.setSubject("買い物リストアプリお問い合わせ") // メールの件名
//        mailComposeVC.setMessageBody(
//            """
//            お名前: \(name)
//            メールアドレス: \(email)
//            
//            お問い合わせ内容:
//            \(message)
//            """, isHTML: false)
//        return mailComposeVC
//    }
//    
//    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
//}
