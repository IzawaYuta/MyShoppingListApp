//
//  MainTabView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/03/21.
//

import SwiftUI

enum TabBarItem: Int, CaseIterable {
    case shoppingList
    case regularList
    
    var title: String? {
        switch self {
        case .shoppingList:
            return "リスト"
        case .regularList:
            return "定期品"
        }
    }
    
    var iconName: String {
        switch self {
        case .shoppingList:
            return "checklist"
        case .regularList:
            return "tray"
        }
    }
}

struct MainTabView: View {
    @Binding var tabSelection: Int
    @Namespace private var animationNamespace
    
    let tabBarItems: [TabBarItem] = TabBarItem.allCases
    
    var body: some View {
        ZStack {
            Capsule()
                .frame(height: 50)
                .foregroundColor(Color(.secondarySystemBackground))
                .shadow(radius: 2)
            
            HStack {
                ForEach(tabBarItems.indices, id: \.self) { index in
                    Button {
                        tabSelection = tabBarItems[index].rawValue
                    } label: {
                        tabItemView(tabBarItem: tabBarItems[index], isActive: tabSelection == tabBarItems[index].rawValue)
                    }
                    .frame(maxWidth: .infinity) // ボタンを均等に配置
                }
            }
            .frame(height: 70)
        }
        .padding(.horizontal)
    }
    
    func tabItemView(tabBarItem: TabBarItem, isActive: Bool) -> some View {
        HStack {
            Spacer()
            Image(systemName: tabBarItem.iconName)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(isActive ? .black : .gray)
                .frame(width: 20, height: 20)
            
            // 選択されているときだけタイトルを表示
            if isActive, let title = tabBarItem.title {
                Text(title)
                    .lineLimit(1)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
            }
            
            Spacer()
        }
        .frame(width: isActive ? 100 : 80, height: 40)
        .background(isActive ? .blue.opacity(0.4) : .clear)
        .cornerRadius(10)
    }
}


#Preview {
    MainTabView(tabSelection: .constant(0))
        .previewLayout(.sizeThatFits)
        .padding(.vertical)
}
