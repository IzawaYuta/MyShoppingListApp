
import SwiftUI

struct MainTabView: View {
    
    @State private var selection: Int = 0
    @State private var store = FolderStore()
    @State private var purchaseStore = PurchaseStore()

    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem {
                    Image(systemName: "square.and.pencil")
                }
                .tag(0)
            RegularItemListView()
                .tabItem {
                    Image(systemName: "square.and.pencil")
                }
                .tag(1)
            PurchaseRecordView()
                .tabItem {
                    Image(systemName: "square.and.pencil")
                }
                .tag(2)
        }
        .environment(store)
        .environment(purchaseStore)
    }
}

#Preview {
    MainTabView()
}
