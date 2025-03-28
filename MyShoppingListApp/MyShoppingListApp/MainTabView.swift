//
//  MainTabView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/03/21.
//

import SwiftUICore

import SwiftUI
//
//enum TabBarItem: Int, CaseIterable {
//    case shoppingList
//    case regularList
//    case aaa
//    case bbb
//    
//    var title: String? {
//        switch self {
//        case .shoppingList:
//            return "List"
//        case .regularList:
//            return "Regular"
//        case .aaa:
//            return "aaa"
//        case .bbb:
//            return "bbb"
//        }
//    }
//    
//    var iconName: String {
//        switch self {
//        case .shoppingList:
//            return "checklist"
//        case .regularList:
//            return "tray"
//        case .aaa:
//            return "star"
//        case .bbb:
//            return "eraser.fill"
//        }
//    }
//}
//
//struct MainTabView: View {
//    @Binding var tabSelection: Int
//    @Namespace private var animationNamespace
//    
//    let tabBarItems: [TabBarItem] = TabBarItem.allCases
//    
//    var body: some View {
//        ZStack {
//            Capsule()
//                .frame(height: 50)
//                .foregroundColor(Color.purple.opacity(0.2))
//                .shadow(radius: 2)
//
//            HStack {
//                ForEach(tabBarItems.indices, id: \.self) { index in
//                    Button {
//                        tabSelection = tabBarItems[index].rawValue
//                    } label: {
//                        tabItemView(tabBarItem: tabBarItems[index], isActive: tabSelection == tabBarItems[index].rawValue)
//                    }
//                    .frame(maxWidth: .infinity) // ボタンを均等に配置
//                }
//            }
//            .frame(height: 70)
//        }
//        .padding(.horizontal)
//    }
//    
//    func tabItemView(tabBarItem: TabBarItem, isActive: Bool) -> some View {
//        HStack {
//            Spacer()
//            Image(systemName: tabBarItem.iconName)
//                .resizable()
//                .renderingMode(.template)
//                .foregroundColor(isActive ? .black : .gray)
//                .frame(width: 20, height: 20)
//            
//            // 選択されているときだけタイトルを表示
//            if isActive, let title = tabBarItem.title {
//                Text(title)
//                    .lineLimit(1)
//                    .font(.system(size: 14))
//                    .foregroundColor(.black)
//            }
//            
//            Spacer()
//        }
//        .frame(width: isActive ? .infinity : 80, height: 40)
//        .background(isActive ? .purple.opacity(0.4) : .clear)
//        .cornerRadius(30)
//    }
//}
//
//
//#Preview {
//    MainTabView(tabSelection: .constant(0))
//        .previewLayout(.sizeThatFits)
//        .padding(.vertical)
//}

enum TabBarItems: Int, CaseIterable {
    case shoppingList
    case regularList
    case setting
    
    var title: String {
        switch self {
        case .shoppingList:
            return "ShopList"
        case .regularList:
            return "RegularList"
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
        case .setting:
            return "Setting"
        }
    }
}

struct MainTabView: View {
    
    @State var selectedTab = 0 // 選択中のタブインデックス
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                CategoryListView()
                    .tag(0)
                
                RegularCategoryListView()
                    .tag(1)
            }
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

extension MainTabView {
    func CustomTabItem(imageName: String, title: String, isActive: Bool) -> some View {
        HStack(spacing: 10) {
            Spacer()
            Image(imageName)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(isActive ? .black : .gray)
                .scaleEffect(isActive ? 1.5 : 1)
                .frame(width: 20, height: 20)
            if isActive {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(isActive ? .white : .gray)
            }
            Spacer()
        }
//        .frame(width: isActive ? .infinity : 60, height: 60)
//        .background(isActive ? .pink.opacity(0.4) : .clear)
//        .cornerRadius(30)
//    }
        .frame(width: isActive ? .infinity : 60, height: 60)
        .background(
            ZStack {
                if isActive {
                    Color.pink.opacity(0.4) // 背景色
                        .cornerRadius(30)
                        .offset(x: isActive ? 0 : 60) // スライドアニメーション
                }
            }
        )
//        .animation(.easeInOut(duration: 0.2), value: isActive) // アニメーションの適用
    }
}

#Preview {
    MainTabView()
}
