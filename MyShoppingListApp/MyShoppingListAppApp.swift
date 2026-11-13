
import SwiftUI
import SwiftData
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}

@main
struct MyShoppingListAppApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
//    var sharedModelContainer: ModelContainer = {
//        // 公開する最初の形（バージョン1）を使い、移行の計画をつなぐ
//        let schema = Schema(versionedSchema: SchemaV1.self)
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//        
//        do {
//            return try ModelContainer(
//                for: schema,
//                migrationPlan: AppMigrationPlan.self,
//                configurations: [modelConfiguration]
//            )
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()
    
    var sharedModelContainer: ModelContainer = {
        // 公開する最初の形（バージョン1）を使い、移行の計画をつなぐ
        let schema = Schema(versionedSchema: SchemaV1.self)
        
        // UIテストのときは、保存せずメモリ上だけで動かす（毎回、空の状態で始める）
        let isUITesting = CommandLine.arguments.contains("-UITesting")
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isUITesting)
        
        do {
            return try ModelContainer(
                for: schema,
                migrationPlan: AppMigrationPlan.self,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
