
import Foundation
import SwiftData

/// 定期アイテムの自動追加
enum RecurringItemRunner {
    
    /// 新しく登録した定期アイテムを保存する
    /// 開始日が今日のときだけ、その場で自動追加も動かす（過去・未来の日付のときは動かさない）
    @MainActor
    static func register(_ draft: RecurringItemDraft, in context: ModelContext) {
        context.insert(RecurringItem(draft: draft))
        guard Calendar.current.isDateInToday(draft.startDate) else { return }
        try? context.save()   // 追加した定期アイテムを、検索で見つけられるように保存しておく
        addDueItems(in: context)
    }
    
    /// 今日までの予定日を、処理済みにする
    /// 開始日や頻度を編集したとき、一時停止から有効に戻したときに呼ぶ
    /// 変更後の「次の予定日」から追加されるようにするため（その場では追加されない）
    static func markProcessedThroughToday(_ item: RecurringItem, now: Date = .now) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        // 今日以前の予定日がなければ（開始日が未来など）、記録は空にする
        item.lastAddedDate = latestDueDate(for: item, today: today, calendar: calendar)
    }
    
    /// アプリを開いたときに呼ぶ。追加日が来ている定期アイテムを、追加先のフォルダに追加する
    /// 何回分たまっていても、追加するのは1回だけ
    @MainActor
    static func addDueItems(in context: ModelContext, now: Date = .now) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        
        // 有効（一時停止でない）の定期アイテムだけが対象
        let descriptor = FetchDescriptor<RecurringItem>(
            predicate: #Predicate<RecurringItem> { $0.isActive }
        )
        guard let items = try? context.fetch(descriptor), !items.isEmpty else { return }
        let folders = (try? context.fetch(FetchDescriptor<FolderNode>())) ?? []
        
        for item in items {
            // 終了日の翌日以降は、追加しない（終了日の当日までは追加する）
            if item.hasEndDate, today > calendar.startOfDay(for: item.endDate) { continue }
            
            // 今日以前で一番新しい追加予定日（まだ来ていない、または終了日を過ぎていれば対象外）
            guard let due = latestDueDate(for: item, today: today, calendar: calendar) else { continue }
            // この回は、すでに追加済み
            if let last = item.lastAddedDate, last >= due { continue }
            
            for folderID in item.folderIDs {
                // 削除されたフォルダは飛ばす
                guard let node = folders.first(where: { $0.id == folderID }) else { continue }
                
                // 同じ名前の未完了アイテムがあれば追加しない
                if node.items.contains(where: { $0.name == item.name && !$0.isDone }) {
                    continue
                }
                
                node.addItem(name: item.name, isPriority: item.isPriority, isAutoAdded: true, in: context)
            }
            
            // 追加しなかった場合も、この回は処理済みとして記録する
            item.lastAddedDate = due
        }
    }
    
    /// 今日以前で一番新しい追加予定日
    /// 予定日は、開始日から「頻度の間隔 × 回数」で数える（月末の日付がずれないように）
    private static func latestDueDate(for item: RecurringItem,
                                      today: Date,
                                      calendar: Calendar) -> Date? {
        let start = calendar.startOfDay(for: item.startDate)
        let end: Date? = item.hasEndDate ? calendar.startOfDay(for: item.endDate) : nil
        let limit = end.map { min($0, today) } ?? today
        guard limit >= start else { return nil }
        
        let step = item.frequency.step
        let units = calendar.dateComponents([step.component], from: start, to: limit)
            .value(for: step.component) ?? 0
        
        var count = units / step.value
        while count >= 0 {
            if let date = calendar.date(byAdding: step.component, value: step.value * count, to: start),
               date <= limit {
                return date
            }
            count -= 1
        }
        return nil
    }
}
