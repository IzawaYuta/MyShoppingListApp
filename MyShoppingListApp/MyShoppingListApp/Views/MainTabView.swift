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
            return "Sopping"
        case .regularList:
            return "Regular"
        case .delete:
            return "Completed"
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
            return "Trash"
        case .setting:
            return "Setting"
        }
    }
    
    var iconSize: CGSize {
        switch self {
        case .shoppingList:
            return CGSize(width: 23, height: 23)
        case .regularList:
            return CGSize(width: 23, height: 23)
        case .delete:
            return CGSize(width: 30, height: 30)
        case .setting:
            return CGSize(width: 27, height: 27)
        }
    }
}

struct MainTabView: View {
    
    @State var selectedTab = 0
    @StateObject private var keyboard = KeyboardResponder()
    @Environment(\.colorScheme) var colorScheme
    
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
                                CustomTabItem(imageName: item.iconName,
                                              title: item.title,
                                              isActive: (selectedTab == item.rawValue),
                                              iconSize: item.iconSize)
                            }
                        }
                    }
                    .padding(6)
                }
                .frame(height: 70)
                //                .background(.pink.opacity(0.2))
                .background(
                    (colorScheme == .dark ? Color.white : Color.pink).opacity(0.2)
                )
                .cornerRadius(35)
                .padding(.horizontal, 26)
                
            }
        }
    }
}

extension MainTabView {
    func CustomTabItem(imageName: String,
                       title: String,
                       isActive: Bool,
                       iconSize: CGSize
    ) -> some View {
        
        HStack(spacing: 10) {
            Spacer()
            Image(imageName)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(isActive ? .black : .gray)
                .scaleEffect(1.2)
                .frame(width: iconSize.width, height: iconSize.height)
            if isActive {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(isActive ? .white : .gray)
            }
            Spacer()
        }
        .frame(width: isActive ? .infinity : 50, height: 60)
        .background(
            ZStack {
                if colorScheme == .dark {
                    if isActive {
                        Color(red: 0.7, green: 0.3, blue: 0.5)
                            .cornerRadius(30)
                            .offset(x: isActive ? 0 : 60)
                    }
                } else {
                    if isActive {
                        Color.pink.opacity(0.4)
                            .cornerRadius(30)
                            .offset(x: isActive ? 0 : 60)
                    }
                }
            }
        )
    }
}

#Preview {
    MainTabView()
}
