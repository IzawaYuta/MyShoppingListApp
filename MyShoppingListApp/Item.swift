//
//  Item.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2026/10/27.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
