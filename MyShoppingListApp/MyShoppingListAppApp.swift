//
//  MyShoppingListAppApp.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2026/10/27.
//

import SwiftUI
import SwiftData

@main
struct MyShoppingListAppApp: App {
    var sharedModelContainer: ModelContainer = {
        // 公開する最初の形（バージョン1）を使い、移行の計画をつなぐ
        let schema = Schema(versionedSchema: SchemaV1.self)
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
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
