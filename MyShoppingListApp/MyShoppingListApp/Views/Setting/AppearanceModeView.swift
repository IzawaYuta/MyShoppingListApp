//
//  AppearanceModeView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/04/07.
//

import SwiftUI

enum AppearanceMode: Int {
    case systemMode
    case lightMode
    case darkMode
    
    var colorScheme: ColorScheme? {
        switch self {
        case .systemMode:
            return .none
        case .lightMode:
            return .light
        case .darkMode:
            return .dark
        }
    }
}

struct AppearanceModeView: View {
    @AppStorage(wrappedValue: 0, "appearanceMode") var appearanceMode
    
    var body: some View {
        List {
            HStack {
                Text("外観モード")
                Picker("", selection: $appearanceMode) {
                    Text("システム")
                        .tag(0)
                    Text("ライト")
                        .tag(1)
                    Text("ダーク")
                        .tag(2)
                }
                .pickerStyle(.menu)
            }
        }
    }
}

#Preview {
    AppearanceModeView()
}
