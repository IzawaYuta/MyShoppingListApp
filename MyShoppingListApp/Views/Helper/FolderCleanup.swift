
import Foundation
import SwiftData

/// フォルダを削除したときの後始末
/// 定期アイテムとよく買うものは、追加先をフォルダの id だけで覚えているため、
/// フォルダが消えたら、その id も取り除く
enum FolderCleanup {
    
    /// フォルダを削除する。配下のフォルダとアイテムも一緒に削除される（cascade）
    /// 削除するフォルダと、配下のフォルダすべての id を、追加先から取り除く
    @MainActor
    static func delete(_ folder: FolderNode, in context: ModelContext) {
        let ids = Set(allIDs(of: folder))
        removeFolderIDs(ids, in: context)
        context.delete(folder)
    }
    
    /// 存在しないフォルダの id を、追加先から取り除く（アプリを開いたときに呼ぶ）
    @MainActor
    static func removeDanglingIDs(in context: ModelContext) {
        let folders = (try? context.fetch(FetchDescriptor<FolderNode>())) ?? []
        let existing = Set(folders.map(\.id))
        
        let recurringItems = (try? context.fetch(FetchDescriptor<RecurringItem>())) ?? []
        for item in recurringItems where item.folderIDs.contains(where: { !existing.contains($0) }) {
            item.folderIDs = item.folderIDs.filter { existing.contains($0) }
        }
        
        let frequentItems = (try? context.fetch(FetchDescriptor<FrequentItem>())) ?? []
        for item in frequentItems where item.folderIDs.contains(where: { !existing.contains($0) }) {
            item.folderIDs = item.folderIDs.filter { existing.contains($0) }
        }
    }
    
    // MARK: - 内部の処理
    
    /// フォルダと、配下のフォルダすべての id
    private static func allIDs(of folder: FolderNode) -> [UUID] {
        [folder.id] + folder.children.flatMap { allIDs(of: $0) }
    }
    
    /// 指定した id を、定期アイテムとよく買うものの追加先から取り除く
    @MainActor
    private static func removeFolderIDs(_ ids: Set<UUID>, in context: ModelContext) {
        let recurringItems = (try? context.fetch(FetchDescriptor<RecurringItem>())) ?? []
        for item in recurringItems where item.folderIDs.contains(where: { ids.contains($0) }) {
            item.folderIDs.removeAll { ids.contains($0) }
        }
        
        let frequentItems = (try? context.fetch(FetchDescriptor<FrequentItem>())) ?? []
        for item in frequentItems where item.folderIDs.contains(where: { ids.contains($0) }) {
            item.folderIDs.removeAll { ids.contains($0) }
        }
    }
}
