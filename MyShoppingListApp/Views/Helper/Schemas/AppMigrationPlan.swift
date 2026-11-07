
import SwiftData

/// スキーマの移行の計画
/// 公開後にモデルを変えるときは、SchemaV2 を作って、schemas に足し、stages に移行の段階を書く
enum AppMigrationPlan: SchemaMigrationPlan {
    
    /// バージョンの一覧（古い順）
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self]
    }
    
    /// バージョン間の移行の段階（バージョンが1つだけの今は、空）
    static var stages: [MigrationStage] {
        []
    }
}
