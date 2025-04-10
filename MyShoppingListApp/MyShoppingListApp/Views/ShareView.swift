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
    @State private var isOn = false
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 50) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.white)
                    .shadow(color: .gray.opacity(0.5), radius: 10)
                    .frame(width: 350, height: 150)
                    .padding()
                Text("共有をONにすると共同編集が有効になります。\n 共有を有効にする場合は、アカウントの登録が\n必要になります。")
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.8))
                    .offset(x: -40, y: -50)
            }
            List {
                ForEach(categoryListModel) { list in
                    HStack {
                        Text(list.name)
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { list.isOn },
                            set: { newValue in
                                let realm = try! Realm()
                                if let thawList = list.thaw() {
                                    try! realm.write {
                                        thawList.isOn = newValue
                                    }
                                }
                                if newValue {
                                    ShareLink(item: "カテゴリー共有", preview: SharePreview("メッセージです", image: Image("MyImage"))) {
                                        Label("カテゴリーを共有", systemImage: "square.and.arrow.up")
                                    }
                                }
                            }
                        ))
                        .labelsHidden()
                    }
                }
            }
            .listStyle(.inset)
        }
        .padding(.horizontal)
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
