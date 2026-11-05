
import SwiftUI
import SwiftData

struct MainTabView: View {
    
    @State private var selection: Int = 0
    @State private var frequentStore = FrequentItemStore()
    @State private var toastCenter = ToastCenter()

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
        .environment(frequentStore)
        .toastHost(toastCenter)
    }
}

#Preview {
    MainTabView()
        .modelContainer(PreviewData.container())
}
