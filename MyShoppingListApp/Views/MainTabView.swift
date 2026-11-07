
import SwiftUI
import SwiftData

struct CustomModifier: ViewModifier {
    let isSelected: Bool
    
    func body(content: Content) -> some View {
        content
            .environment(
                \.symbolVariants,
                 isSelected ? .fill : .none
            )
            .foregroundStyle(.black)
    }
}

struct MainTabView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var selection: Int = 0
    @State private var toastCenter = ToastCenter()

    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem {
                    Image(systemName: "cart")
                        .modifier(CustomModifier(isSelected: selection == 0))

                }
                .tag(0)
            FrequentItemListView()
                .tabItem {
                    Image(systemName: "star")
                        .modifier(CustomModifier(isSelected: selection == 1))
                }
                .tag(1)
            RegularItemListView()
                .tabItem {
                    Image(systemName: "calendar.badge.clock")
                        .modifier(CustomModifier(isSelected: selection == 2))
                }
                .tag(2)
            PurchaseRecordView()
                .tabItem {
                    Image(systemName: "receipt")
                        .modifier(CustomModifier(isSelected: selection == 3))
                }
                .tag(3)
        }
        .tint(.black)
        .toastHost(toastCenter)
        .task {
            // アプリを起動したとき
            // 先に、存在しないフォルダの id を掃除してから、自動追加する
            FolderCleanup.removeDanglingIDs(in: modelContext)
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
