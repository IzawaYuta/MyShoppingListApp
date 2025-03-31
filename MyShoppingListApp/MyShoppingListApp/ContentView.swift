//
//  ContentView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/03/21.
//

import SwiftUI

struct ContentView: View {
    @AppStorage(wrappedValue: 1, "appearanceMode") var appearanceMode
    
    var body: some View {
        MainTabView()
            .preferredColorScheme(AppearanceMode(rawValue: appearanceMode)?.colorScheme)
    }
}

#Preview {
    ContentView()
}
