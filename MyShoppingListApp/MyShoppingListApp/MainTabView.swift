//
//  MainTabView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/03/21.
//

import SwiftUI

struct MainTabView: View {
    
    @State private var selection = 1
    
    var body: some View {
        TabView(selection: $selection) {
            CategoryListView()
                .tabItem {
                    Image(systemName: "checklist")
                }
                .tag(1)
            RegularCategoryListView()
                .tabItem {
                    Image(systemName: "tray")
                }
                .tag(2)
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
}
