//
//  RegularListView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/03/21.
//

import SwiftUI
import RealmSwift

class RegularListViewModel: Object, Identifiable {
    @Persisted var id = UUID()
    @Persisted var regularName: String
    
    convenience init(regularName: String) {
        self.init()
        self.regularName = regularName
    }
}

struct RegularListView: View {
    
    @State private var regularListViewModel: [RegularListViewModel] = [RegularListViewModel(regularName: "あ")]
    
    var body: some View {
        List(regularListViewModel) { list in
            Text(list.regularName)
        }
    }
}

#Preview {
    RegularListView()
}
