//
//  ContentView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/03/21.
//

import SwiftUI

struct ContentView: View {
        @State private var tabSelect = 0
        
        var body: some View {
            TabView(selection: $tabSelect) {
                CategoryListView()
                    .tag(1)
                RegularCategoryListView()
                    .tag(2)
            }
            .overlay(alignment: .bottom) {
                MainTabView(tabSelection: $tabSelect)
        }
    }
}

#Preview {
    ContentView()
}
