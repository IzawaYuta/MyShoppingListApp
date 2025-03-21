//
//  MainTabView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/03/21.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            CategoryListView()
                .tabItem {
                    Label("", systemImage: "checklist")
                }
            RegularCategoryListView()
                .tabItem {
                    Label("", systemImage: "tray")
                }
        }
    }
}

#Preview {
    MainTabView()
}
