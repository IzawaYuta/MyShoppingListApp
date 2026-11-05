
import SwiftUI
import SwiftData

struct MainTabView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var selection: Int = 0
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
        .toastHost(toastCenter)
        .task {
            // アプリを起動したとき
            RecurringItemRunner.addDueItems(in: modelContext)
        }
        .onChange(of: scenePhase) { _, newPhase in
            // 別のアプリやホーム画面から戻ってきたとき
            if newPhase == .active {
                RecurringItemRunner.addDueItems(in: modelContext)
            }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(PreviewData.container())
}
