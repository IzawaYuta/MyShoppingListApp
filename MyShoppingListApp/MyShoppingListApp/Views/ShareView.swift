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
//        VStack(spacing: 15) {
//            ForEach(categoryListModel) { list in
//                ZStack {
//                    RoundedRectangle(cornerRadius: 10)
//                        .foregroundColor(.white)
//                        .shadow(color: .black.opacity(0.5), radius: 5)
//                        .frame(width: 350, height: 50)
//                    HStack {
//                        Text(list.name)
//                        Spacer()
//                        Toggle("トグル", isOn: $isOn)
//                            .labelsHidden()
//                    }
//                    .padding(.horizontal)
//                }
//            }
//        }
        List {
            ForEach(categoryListModel) { list in
                Section(header: Text(list.name)
                    .font(.title2)
                    .foregroundColor(.black)
                ) {
                    ForEach(categoryListModel) { each in
                        Toggle("", isOn: Binding(
                            get: { each.isOn },
                            set: { newValue in
                                each.isOn = newValue // 状態変更時に値を更新
                            }
                        ))
                    }
                }
            }
        }
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
