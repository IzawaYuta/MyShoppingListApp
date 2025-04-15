//
//  MainTabView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/03/21.
//

import SwiftUICore
import SwiftUI

enum TabBarItems: Int, CaseIterable {
    case shoppingList
    case regularList
    case delete
    case setting
    
    var title: String {
        switch self {
        case .shoppingList:
            return "ShopList"
        case .regularList:
            return "RegularList"
        case .delete:
            return ""
        case .setting:
            return "Setting"
        }
    }
    
    var iconName: String {
        switch self {
        case .shoppingList:
            return "ShoppingList"
        case .regularList:
            return "RegularList"
        case .delete:
            return "delete"
        case .setting:
            return "Setting"
        }
    }
}

struct MainTabView: View {
    
    @State var selectedTab = 0
    @StateObject private var keyboard = KeyboardResponder()
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                CategoryListView()
                    .tag(0)
                RegularCategoryListView()
                    .tag(1)
                DeleteItemView()
                    .tag(2)
                SettingView()
                    .tag(3)
            }
            if !keyboard.isVisible {
                ZStack {
                    HStack {
                        ForEach((TabBarItems.allCases), id: \.self) { item in
                            Button{
                                selectedTab = item.rawValue
                            } label: {
                                CustomTabItem(imageName: item.iconName, title: item.title, isActive: (selectedTab == item.rawValue))
                            }
                        }
                    }
                    .padding(6)
                }
                .frame(height: 70)
                .background(.pink.opacity(0.2))
                .cornerRadius(35)
                .padding(.horizontal, 26)
            }
        }
    }
}

extension MainTabView {
    func CustomTabItem(imageName: String, title: String, isActive: Bool) -> some View {
        HStack(spacing: 10) {
            Spacer()
            Image(imageName)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(isActive ? .black : .gray)
                .scaleEffect(isActive ? 1.5 : 1.3)
                .frame(width: 20, height: 20)
            if isActive {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(isActive ? .white : .gray)
            }
            Spacer()
        }
        .frame(width: isActive ? .infinity : 75, height: 60)
        .background(
            ZStack {
                if isActive {
                    Color.pink.opacity(0.4)
                        .cornerRadius(30)
                        .offset(x: isActive ? 0 : 60)
                }
            }
        )
    }
}

#Preview {
    MainTabView()
}
