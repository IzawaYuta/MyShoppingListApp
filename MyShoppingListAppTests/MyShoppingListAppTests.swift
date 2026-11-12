//
//  MyShoppingListAppTests.swift
//  MyShoppingListAppTests
//
//  Created by Engineer MacBook Air on 2026/10/27.
//
//  対象: 列挙型 / SwiftData モデル（SchemaV1）/ RecurringItemDraft / 移行計画
//  （定期アイテムの自動追加・フォルダid掃除などの「処理」は、コードを受け取ってから追加）
//

import Testing
import Foundation
import SwiftData
import UIKit
@testable import MyShoppingListApp

// MARK: - 共通ヘルパー

/// コンテナを保持したままコンテキストを使うための入れ物
@MainActor
private struct TestStore {
    let container: ModelContainer
    var context: ModelContext { container.mainContext }
    
    init() throws {
        container = try ModelContainer(
            for: Schema(versionedSchema: SchemaV1.self),
            migrationPlan: AppMigrationPlan.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }
    
    func count<T: PersistentModel>(_ type: T.Type) throws -> Int {
        try context.fetchCount(FetchDescriptor<T>())
    }
}

private let cal = Calendar.current

private func day(_ y: Int, _ m: Int, _ d: Int) -> Date {
    cal.date(from: DateComponents(year: y, month: m, day: d))!
}

private func ymd(_ date: Date) -> [Int] {
    let c = cal.dateComponents([.year, .month, .day], from: date)
    return [c.year!, c.month!, c.day!]
}

// MARK: - FolderLimit

@Suite("FolderLimit")
struct FolderLimitTests {
    @Test func 最大階層は3() {
        #expect(FolderLimit.maxDepth == 3)
    }
    
    @Test func アイテムを入れられる最小階層は1階層目() {
        // level 1 = カテゴリー画面から最初に遷移した画面。ここからアイテムを追加できる
        // カテゴリー画面（ホーム）自体にはアイテムを入れない
        #expect(FolderLimit.itemMinLevel == 1)
    }
    
    @Test func アイテム最小階層は最大階層を超えない() {
        #expect(FolderLimit.itemMinLevel >= 1)
        #expect(FolderLimit.itemMinLevel <= FolderLimit.maxDepth)
    }
}

// MARK: - CustomIconFolder

@Suite("CustomIconFolder")
struct CustomIconFolderTests {
    @Test func idはrawValueと同じ() {
        for icon in CustomIconFolder.allCases {
            #expect(icon.id == icon.rawValue)
        }
    }
    
    @Test func 全てのrawValueが重複しない() {
        let raws = CustomIconFolder.allCases.map(\.rawValue)
        #expect(Set(raws).count == raws.count)
    }
    
    @Test(arguments: CustomIconFolder.allCases)
    func Assetsに同名の画像が存在する(icon: CustomIconFolder) {
        #expect(UIImage(named: icon.rawValue) != nil, "Assets に \(icon.rawValue) がありません")
    }
    
    @Test func 存在しない名前はnil() {
        #expect(CustomIconFolder(rawValue: "unknown") == nil)
        #expect(CustomIconFolder(rawValue: "") == nil)
        #expect(CustomIconFolder(rawValue: "Apple") == nil)
    }
}

// MARK: - RecurrenceFrequency

@Suite("RecurrenceFrequency")
struct RecurrenceFrequencyTests {
    @Test func rawValueは保存用の固定名() {
        #expect(RecurrenceFrequency.daily.rawValue == "daily")
        #expect(RecurrenceFrequency.weekly.rawValue == "weekly")
        #expect(RecurrenceFrequency.biweekly.rawValue == "biweekly")
        #expect(RecurrenceFrequency.monthly.rawValue == "monthly")
        #expect(RecurrenceFrequency.yearly.rawValue == "yearly")
        #expect(RecurrenceFrequency.allCases.count == 5) // 公開後は減らさない
    }
    
    @Test func 表示名() {
        #expect(RecurrenceFrequency.daily.title == "毎日")
        #expect(RecurrenceFrequency.weekly.title == "毎週")
        #expect(RecurrenceFrequency.biweekly.title == "隔週")
        #expect(RecurrenceFrequency.monthly.title == "毎月")
        #expect(RecurrenceFrequency.yearly.title == "毎年")
    }
    
    @Test(arguments: [
        (RecurrenceFrequency.daily,    [2026, 11, 9]),
        (RecurrenceFrequency.weekly,   [2026, 11, 15]),
        (RecurrenceFrequency.biweekly, [2026, 11, 22]),
        (RecurrenceFrequency.monthly,  [2026, 12, 8]),
        (RecurrenceFrequency.yearly,   [2027, 11, 8]),
    ])
    func stepで次の日付を求められる(frequency: RecurrenceFrequency, expected: [Int]) {
        let next = cal.date(byAdding: frequency.step.component,
                            value: frequency.step.value, to: day(2026, 11, 8))!
        #expect(ymd(next) == expected)
    }
    
    @Test func Codableで保存と復元ができる() throws {
        for freq in RecurrenceFrequency.allCases {
            let data = try JSONEncoder().encode(freq)
            #expect(try JSONDecoder().decode(RecurrenceFrequency.self, from: data) == freq)
        }
    }
    
    @Test func 存在しないrawValueはnil() {
        #expect(RecurrenceFrequency(rawValue: "hourly") == nil)
        #expect(RecurrenceFrequency(rawValue: "Daily") == nil)
    }
    
    @Test func 不正な値のデコードは失敗する() {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(RecurrenceFrequency.self, from: Data("\"hourly\"".utf8))
        }
    }
    
    @Test func 月末の毎月は翌月末に丸められる() {
        let next = cal.date(byAdding: .month, value: 1, to: day(2026, 1, 31))!
        #expect(ymd(next) == [2026, 2, 28])
    }
}

// MARK: - FolderNode

@Suite("FolderNode")
@MainActor
struct FolderNodeTests {
    
    // 正常系
    @Test func 初期値() {
        let f = FolderNode(name: "食品")
        #expect(f.name == "食品")
        #expect(f.tintIndex == 0)
        #expect(f.customIconName == nil)
        #expect(f.sortOrder == 0)
        #expect(f.isFavorite == false)
        #expect(f.parent == nil)
        #expect(f.children.isEmpty)
        #expect(f.items.isEmpty)
    }
    
    @Test func idは作成ごとに別() {
        #expect(FolderNode(name: "A").id != FolderNode(name: "A").id)
    }
    
    @Test func アイコンはrawValueで保存され取り出せる() {
        let f = FolderNode(name: "食品", customIcon: .apple)
        #expect(f.customIconName == "apple")
        #expect(f.customIcon == .apple)
        f.customIcon = .tomato01
        #expect(f.customIconName == "tomato01")
        f.customIcon = nil
        #expect(f.customIconName == nil)
    }
    
    @Test func 頭文字は名前の先頭1文字() {
        #expect(FolderNode(name: "食品").initial == "食")
        #expect(FolderNode(name: "Apple").initial == "A")
    }
    
    @Test func addItemは一番下に並ぶ() throws {
        let store = try TestStore()
        let f = FolderNode(name: "野菜")
        store.context.insert(f)
        
        let a = f.addItem(name: "トマト", in: store.context)
        let b = f.addItem(name: "ナス", in: store.context)
        let c = f.addItem(name: "ニンジン", in: store.context)
        
        let orders: [Int] = [a.sortOrder, b.sortOrder, c.sortOrder]
        #expect(orders == [0, 1, 2])
        #expect(a.folder === f)
        #expect(f.items.count == 3)
        #expect(f.sortedItems.map(\.name) == ["トマト", "ナス", "ニンジン"])
    }
    
    @Test func addItemのフラグが反映される() throws {
        let store = try TestStore()
        let f = FolderNode(name: "野菜")
        store.context.insert(f)
        let item = f.addItem(name: "牛乳", isPriority: true, isAutoAdded: true, in: store.context)
        #expect(item.isPriority == true)
        #expect(item.isAutoAdded == true)
        #expect(item.isDone == false)
    }
    
    @Test func 子フォルダとアイテムはsortOrder順に取れる() throws {
        let store = try TestStore()
        let root = FolderNode(name: "root")
        let c1 = FolderNode(name: "後", sortOrder: 2)
        let c2 = FolderNode(name: "先", sortOrder: 1)
        [root, c1, c2].forEach { store.context.insert($0) }
        c1.parent = root
        c2.parent = root
        #expect(root.sortedChildren.map(\.name) == ["先", "後"])
    }
    
    @Test func totalItemCountは子フォルダ内も数える() throws {
        let store = try TestStore()
        let root = FolderNode(name: "root")
        let child = FolderNode(name: "child")
        let grand = FolderNode(name: "grand")
        [root, child, grand].forEach { store.context.insert($0) }
        child.parent = root
        grand.parent = child
        child.addItem(name: "a", in: store.context)
        grand.addItem(name: "b", in: store.context)
        grand.addItem(name: "c", in: store.context)
        #expect(root.totalItemCount == 3)
        #expect(child.totalItemCount == 3)
        #expect(grand.totalItemCount == 2)
    }
    
    @Test func rootsDescriptorは最上位だけをsortOrder順に返す() throws {
        let store = try TestStore()
        let r1 = FolderNode(name: "二番", sortOrder: 1)
        let r0 = FolderNode(name: "一番", sortOrder: 0)
        let child = FolderNode(name: "子", sortOrder: 0)
        [r1, r0, child].forEach { store.context.insert($0) }
        child.parent = r0
        try store.context.save()
        
        let roots = try store.context.fetch(FolderNode.rootsDescriptor)
        #expect(roots.map(\.name) == ["一番", "二番"])
    }
    
    @Test func 初回起動時はフォルダが空() throws {
        let store = try TestStore()
        #expect(try store.context.fetch(FolderNode.rootsDescriptor).isEmpty)
    }
    
    // 削除（cascade）
    @Test func 親を削除すると配下のフォルダとアイテムも全て削除される() throws {
        let store = try TestStore()
        let root = FolderNode(name: "root")
        let child = FolderNode(name: "child")
        [root, child].forEach { store.context.insert($0) }
        child.parent = root
        root.addItem(name: "親直下", in: store.context)
        child.addItem(name: "子直下", in: store.context)
        try store.context.save()
        
        store.context.delete(root)
        try store.context.save()
        
        #expect(try store.count(FolderNode.self) == 0)
        #expect(try store.count(ShoppingItem.self) == 0)
    }
    
    // 異常系
    @Test func 子を削除しても親は残る() throws {
        let store = try TestStore()
        let root = FolderNode(name: "root")
        let child = FolderNode(name: "child")
        [root, child].forEach { store.context.insert($0) }
        child.parent = root
        try store.context.save()
        
        store.context.delete(child)
        try store.context.save()
        
        #expect(try store.count(FolderNode.self) == 1)
        #expect(root.children.isEmpty)
    }
    
    @Test func アイテムを削除してもフォルダは残る() throws {
        let store = try TestStore()
        let f = FolderNode(name: "野菜")
        store.context.insert(f)
        let item = f.addItem(name: "トマト", in: store.context)
        try store.context.save()
        
        store.context.delete(item)
        try store.context.save()
        
        #expect(try store.count(FolderNode.self) == 1)
        #expect(f.items.isEmpty)
    }
    
    @Test func 不正なアイコン名はnilとして扱われる() {
        let f = FolderNode(name: "食品")
        f.customIconName = "deleted_image"
        #expect(f.customIcon == nil) // 読み込みエラーにならない
    }
    
    @Test func 空の名前でも頭文字は空文字() {
        #expect(FolderNode(name: "").initial == "")
    }
    
    @Test func tintIndexがパレットより大きくても取得できる() {
        let f = FolderNode(name: "食品", tintIndex: 999)
        _ = f.tint // 範囲外でクラッシュしない
    }
}

// MARK: - ShoppingItem

@Suite("ShoppingItem")
@MainActor
struct ShoppingItemTests {
    @Test func 初期値() {
        let item = ShoppingItem(name: "牛乳")
        #expect(item.isDone == false)
        #expect(item.isPriority == false)
        #expect(item.purchasedAt == nil)
        #expect(item.isAutoAdded == false)
        #expect(item.quantity == "")
        #expect(item.folder == nil)
    }
    
    @Test func 完了で作成すると購入日が入る() {
        #expect(ShoppingItem(name: "牛乳", isDone: true).purchasedAt != nil)
    }
    
    @Test func setDoneで購入日の記録と消去ができる() {
        let item = ShoppingItem(name: "牛乳")
        item.setDone(true)
        #expect(item.isDone == true)
        #expect(item.purchasedAt != nil)
        item.setDone(false)
        #expect(item.isDone == false)
        #expect(item.purchasedAt == nil)
    }
    
    @Test func toggleDoneで切り替わる() {
        let item = ShoppingItem(name: "牛乳")
        item.toggleDone()
        #expect(item.isDone == true)
        item.toggleDone()
        #expect(item.isDone == false)
    }
    
    @Test func 同じ状態をもう一度設定しても購入日は消えない() {
        let item = ShoppingItem(name: "牛乳")
        item.setDone(true)
        item.setDone(true)
        #expect(item.isDone == true)
        #expect(item.purchasedAt != nil)
    }
}

// MARK: - PurchaseRecord

@Suite("PurchaseRecord")
@MainActor
struct PurchaseRecordTests {
    @Test func 初期値() {
        let r = PurchaseRecord(name: "牛乳", folderName: "食品", purchasedAt: day(2026, 11, 8))
        #expect(r.folderID == nil)
        #expect(r.isPriority == false)
    }
    
    @Test func フォルダ名は文字列のコピーで後から変わらない() {
        let folder = FolderNode(name: "食品")
        let r = PurchaseRecord(name: "牛乳", folderName: folder.name,
                               purchasedAt: .now, folderID: folder.id)
        folder.name = "食料品"
        #expect(r.folderName == "食品")
        #expect(r.folderID == folder.id)
    }
    
    @Test func フォルダを削除しても購入履歴は残る() throws {
        let store = try TestStore()
        let folder = FolderNode(name: "食品")
        store.context.insert(folder)
        store.context.insert(PurchaseRecord(name: "牛乳", folderName: "食品",
                                            purchasedAt: .now, folderID: folder.id))
        try store.context.save()
        
        store.context.delete(folder)
        try store.context.save()
        
        #expect(try store.count(PurchaseRecord.self) == 1)
    }
    
    @Test func 新しい順に並べられる() throws {
        let store = try TestStore()
        store.context.insert(PurchaseRecord(name: "古", folderName: "A", purchasedAt: day(2026, 11, 1)))
        store.context.insert(PurchaseRecord(name: "新", folderName: "A", purchasedAt: day(2026, 11, 8)))
        try store.context.save()
        
        let sorted = try store.context.fetch(FetchDescriptor<PurchaseRecord>(
            sortBy: [SortDescriptor(\.purchasedAt, order: .reverse)]))
        #expect(sorted.map(\.name) == ["新", "古"])
    }
}

// MARK: - RecurringItemDraft / RecurringItem

@Suite("RecurringItem")
@MainActor
struct RecurringItemTests {
    
    // Draft
    @Test func Draftの初期値() {
        let d = RecurringItemDraft()
        #expect(d.name == "")
        #expect(d.folderIDs.isEmpty)
        #expect(d.frequency == .weekly)
        #expect(d.hasEndDate == false)
        #expect(d.isPriority == false)
        #expect(d.notifiesOnAdd == true)
        #expect(d.isActive == true)
        #expect(d.startDate == cal.startOfDay(for: .now))
    }
    
    // 正常系
    @Test func Draftの内容が反映される() {
        let id1 = UUID(), id2 = UUID()
        var d = RecurringItemDraft()
        d.name = "牛乳"
        d.quantity = "2本"
        d.folderIDs = [id1, id2]
        d.startDate = day(2026, 11, 8)
        d.frequency = .monthly
        d.hasEndDate = true
        d.endDate = day(2027, 3, 31)
        d.isPriority = true
        d.notifiesOnAdd = false
        d.isActive = false
        
        let item = RecurringItem(draft: d)
        
        #expect(item.name == "牛乳")
        #expect(item.quantity == "2本")
        #expect(Set(item.folderIDs) == [id1, id2])
        #expect(ymd(item.startDate) == [2026, 11, 8])
        #expect(item.frequency == .monthly)
        #expect(item.hasEndDate == true)
        #expect(ymd(item.endDate) == [2027, 3, 31])
        #expect(item.isPriority == true)
        #expect(item.notifiesOnAdd == false)
        #expect(item.isActive == false)
        #expect(item.lastAddedDate == nil)
    }
    
    @Test func draftプロパティで往復できる() {
        var d = RecurringItemDraft()
        d.name = "卵"
        d.folderIDs = [UUID()]
        d.frequency = .biweekly
        let back = RecurringItem(draft: d).draft
        #expect(back.name == d.name)
        #expect(back.folderIDs == d.folderIDs)
        #expect(back.frequency == .biweekly)
    }
    
    @Test func applyで上書きされる() {
        let item = RecurringItem(draft: RecurringItemDraft())
        var d = RecurringItemDraft()
        d.name = "変更後"
        d.frequency = .yearly
        item.apply(d)
        #expect(item.name == "変更後")
        #expect(item.frequency == .yearly)
    }
    
    @Test(arguments: [
        (RecurrenceFrequency.daily,    "毎日"),
        (RecurrenceFrequency.weekly,   "毎週"),
        (RecurrenceFrequency.biweekly, "隔週"),
        (RecurrenceFrequency.monthly,  "毎月15日"),
        (RecurrenceFrequency.yearly,   "毎年3月15日"),
    ])
    func subtitleの表示(frequency: RecurrenceFrequency, expected: String) {
        var d = RecurringItemDraft()
        d.startDate = day(2026, 3, 15)
        d.frequency = frequency
        #expect(RecurringItem(draft: d).subtitle == expected)
    }
    
    @Test func SwiftDataに保存して取り出せる() throws {
        let store = try TestStore()
        var d = RecurringItemDraft()
        d.name = "牛乳"
        d.frequency = .biweekly
        store.context.insert(RecurringItem(draft: d))
        try store.context.save()
        
        let items = try store.context.fetch(FetchDescriptor<RecurringItem>())
        #expect(items.count == 1)
        #expect(items.first?.frequency == .biweekly)
    }
    
    // isEnded（境界・異常系）
    @Test func 終了日を設定していなければ終了しない() {
        var d = RecurringItemDraft()
        d.hasEndDate = false
        d.endDate = day(2000, 1, 1)
        #expect(RecurringItem(draft: d).isEnded == false)
    }
    
    @Test func 終了日の翌日以降は終了() {
        var d = RecurringItemDraft()
        d.hasEndDate = true
        d.endDate = cal.date(byAdding: .day, value: -1, to: cal.startOfDay(for: .now))!
        #expect(RecurringItem(draft: d).isEnded == true)
    }
    
    @Test func 終了日当日はまだ終了していない() {
        var d = RecurringItemDraft()
        d.hasEndDate = true
        d.endDate = cal.startOfDay(for: .now)
        #expect(RecurringItem(draft: d).isEnded == false)
    }
    
    @Test func 終了日が未来なら終了していない() {
        var d = RecurringItemDraft()
        d.hasEndDate = true
        d.endDate = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: .now))!
        #expect(RecurringItem(draft: d).isEnded == false)
    }
}

// MARK: - FrequentItem

@Suite("FrequentItem")
@MainActor
struct FrequentItemTests {
    @Test func 初期値() {
        let item = FrequentItem(name: "牛乳")
        #expect(item.name == "牛乳")
        #expect(item.isPriority == false)
        #expect(item.quantity == "")
        #expect(item.folderIDs.isEmpty)
    }
    
    @Test func 追加先フォルダidを保持できる() {
        let ids = [UUID(), UUID()]
        let item = FrequentItem(name: "牛乳", isPriority: true, folderIDs: ids)
        #expect(item.isPriority == true)
        #expect(item.folderIDs == ids)
    }
    
    @Test func フォルダを削除してもよく買うものは残る() throws {
        let store = try TestStore()
        let folder = FolderNode(name: "食品")
        store.context.insert(folder)
        store.context.insert(FrequentItem(name: "牛乳", folderIDs: [folder.id]))
        try store.context.save()
        
        store.context.delete(folder)
        try store.context.save()
        
        #expect(try store.count(FrequentItem.self) == 1) // idだけ覚えるので連動しない
    }
}

// MARK: - スキーマ / 移行計画

@Suite("Schema")
struct SchemaTests {
    @Test func バージョンは1_0_0() {
        #expect(SchemaV1.versionIdentifier == Schema.Version(1, 0, 0))
    }
    
    @Test func モデルは5つ() {
        #expect(SchemaV1.models.count == 5)
    }
    
    @Test func 移行計画はV1だけで段階は空() {
        #expect(AppMigrationPlan.schemas.count == 1)
        #expect(AppMigrationPlan.stages.isEmpty)
    }
    
    @MainActor
    @Test func 移行計画つきでコンテナを作れる() throws {
        _ = try TestStore()
    }
}

// MARK: - FolderDisplayMode

@Suite("FolderDisplayMode")
struct FolderDisplayModeTests {
    @Test func 並びはデフォルト_星が上_星のみ() {
        #expect(FolderDisplayMode.allCases == [.standard, .favoritesFirst, .favoritesOnly])
    }
    
    @Test func 表示名() {
        #expect(FolderDisplayMode.standard.title == "デフォルト")
        #expect(FolderDisplayMode.favoritesFirst.title == "お気に入りを上に表示")
        #expect(FolderDisplayMode.favoritesOnly.title == "お気に入りのみ表示")
    }
    
    @Test func idは重複しない() {
        let ids = FolderDisplayMode.allCases.map(\.id)
        #expect(Set(ids).count == ids.count)
    }
    
    @Test func アイコン名は全て空でない() {
        for mode in FolderDisplayMode.allCases {
            #expect(!mode.systemImage.isEmpty)
            #expect(UIImage(systemName: mode.systemImage) != nil, "\(mode.systemImage) は存在しないSF Symbol")
        }
    }
    
    @Test func 存在しないrawValueはnil() {
        #expect(FolderDisplayMode(rawValue: "favorites") == nil)
    }
}

// MARK: - FolderRoute

@Suite("FolderRoute")
@MainActor
struct FolderRouteTests {
    @Test(arguments: [(1, true), (2, true), (3, false)])
    func フォルダを追加できる階層(level: Int, expected: Bool) {
        #expect(FolderRoute(node: FolderNode(name: "A"), level: level).canAddFolder == expected)
    }
    
    @Test(arguments: [(1, true), (2, true), (3, true)])
    func アイテムを入れられる階層(level: Int, expected: Bool) {
        // level 1 = カテゴリー画面から最初に遷移した画面。ここからアイテムを追加できる
        #expect(FolderRoute(node: FolderNode(name: "A"), level: level).canHoldItems == expected)
    }
    
    @Test func レベル0以下はアイテムを入れられない() {
        #expect(FolderRoute(node: FolderNode(name: "A"), level: 0).canHoldItems == false)
    }
    
    @Test func 同じフォルダと階層なら等しい() {
        let node = FolderNode(name: "A")
        let a = FolderRoute(node: node, level: 2)
        let b = FolderRoute(node: node, level: 2)
        #expect(a == b)
        #expect(a.hashValue == b.hashValue)
    }
    
    @Test func 階層が違えば等しくない() {
        let node = FolderNode(name: "A")
        #expect(FolderRoute(node: node, level: 1) != FolderRoute(node: node, level: 2))
    }
    
    @Test func フォルダが違えば等しくない() {
        let a = FolderRoute(node: FolderNode(name: "A"), level: 1)
        let b = FolderRoute(node: FolderNode(name: "A"), level: 1) // 同名でもidが別
        #expect(a != b)
    }
    
    @Test func Setに入れても重複しない() {
        let node = FolderNode(name: "A")
        let set: Set<FolderRoute> = [
            FolderRoute(node: node, level: 1),
            FolderRoute(node: node, level: 1),
            FolderRoute(node: node, level: 2),
        ]
        #expect(set.count == 2)
    }
}

// MARK: - FolderTint

@Suite("FolderTint")
@MainActor
struct FolderTintTests {
    @Test func パレットは空でない() {
        #expect(!FolderTint.palette.isEmpty)
    }
    
    @Test func tintIndexがパレット数以上なら先頭から繰り返す() {
        let count = FolderTint.palette.count
        let wrapped = FolderNode(name: "A", tintIndex: count).tint
        #expect(wrapped.background == FolderTint.palette[0].background)
        #expect(wrapped.foreground == FolderTint.palette[0].foreground)
    }
    
    @Test func tintIndexで色が選ばれる() {
        let f = FolderNode(name: "A", tintIndex: 1)
        #expect(f.tint.background == FolderTint.palette[1].background)
    }
}

// MARK: - ActiveSheet

@Suite("ActiveSheet")
@MainActor
struct ActiveSheetTests {
    @Test func idの値() {
        let node = FolderNode(name: "A")
        #expect(ActiveSheet.folder.id == "folder")
        #expect(ActiveSheet.item.id == "item")
        #expect(ActiveSheet.editFolder(node).id == "edit-\(node.id)")
    }
    
    @Test func 編集シートはフォルダごとにidが違う() {
        let a = ActiveSheet.editFolder(FolderNode(name: "A"))
        let b = ActiveSheet.editFolder(FolderNode(name: "A"))
        #expect(a.id != b.id)
    }
}
