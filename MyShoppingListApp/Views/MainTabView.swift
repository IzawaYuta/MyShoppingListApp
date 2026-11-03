
import SwiftUI

struct MainTabView: View {
    
    @State private var selection: Int = 0
    @State private var store = FolderStore()
    @State private var purchaseStore = PurchaseStore()
    @State private var frequentStore: FrequentItemStore
    @State private var toastCenter = ToastCenter()

    init() {
        let folders = FolderStore()
        _store = State(initialValue: folders)
        // ダミーデータ。実際のデータに切り替える時は FrequentItemStore() にする
        _frequentStore = State(initialValue: .sample(folders: folders))
    }

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
            FrequentItemListView()
            .tabItem { Image(systemName: "star") }   
            .tag(3)
        }
        .environment(store)
        .environment(purchaseStore)
        .environment(frequentStore)
        .toastHost(toastCenter)
    }
}

#Preview {
    MainTabView()
}
