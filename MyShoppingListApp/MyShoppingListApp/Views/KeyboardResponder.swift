//
//  KeyboardResponder.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/04/05.
//

import SwiftUI
import Combine

class KeyboardResponder: ObservableObject {
    @Published var isVisible: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { _ in
                withAnimation {
                    self.isVisible = true
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { _ in
                withAnimation {
                    self.isVisible = false
                }
            }
            .store(in: &cancellables)
    }
}
