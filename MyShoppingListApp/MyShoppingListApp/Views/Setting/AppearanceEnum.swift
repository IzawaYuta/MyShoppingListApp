//
//  AppearanceEnum.swift
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
