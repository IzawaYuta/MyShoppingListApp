
import SwiftUI

struct MainTabView: View {
    
    @State private var selection: Int = 0
    @State private var store = FolderStore()     
    
    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem {
                    Image(systemName: "square.and.pencil")
                }
                .tag(0)
            RegularItemInfoView()
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
    }
}

#Preview {
    MainTabView()
}
