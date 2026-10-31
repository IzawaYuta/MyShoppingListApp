
import SwiftUI

// MARK: - Model

struct PurchaseRecord: Identifiable {
    let id = UUID()
    let name: String
    let folderName: String
    let purchasedAt: Date
}

// MARK: - Dummy data

extension PurchaseRecord {
    static func dummy() -> [PurchaseRecord] {
        let cal = Calendar.current
        let now = Date()
        
        func day(_ offset: Int, hour: Int) -> Date {
            let base = cal.date(byAdding: .day, value: -offset, to: now) ?? now
            return cal.date(bySettingHour: hour, minute: 0, second: 0, of: base) ?? base
        }
        
        return [
            PurchaseRecord(name: "牛乳", folderName: "乳製品", purchasedAt: day(0, hour: 18)),
            PurchaseRecord(name: "卵", folderName: "卵・納豆", purchasedAt: day(0, hour: 17)),
            PurchaseRecord(name: "キャベツ", folderName: "野菜", purchasedAt: day(0, hour: 16)),
            
            PurchaseRecord(name: "食器用洗剤", folderName: "キッチン用品", purchasedAt: day(1, hour: 19)),
            PurchaseRecord(name: "ティッシュ", folderName: "日用品", purchasedAt: day(1, hour: 18)),
            
            PurchaseRecord(name: "鶏むね肉", folderName: "肉・魚", purchasedAt: day(3, hour: 18)),
            PurchaseRecord(name: "食パン", folderName: "パン", purchasedAt: day(3, hour: 17)),
            PurchaseRecord(name: "ヨーグルト", folderName: "乳製品", purchasedAt: day(3, hour: 16)),
            
            PurchaseRecord(name: "トイレットペーパー", folderName: "日用品", purchasedAt: day(6, hour: 14)),
            PurchaseRecord(name: "コーヒー豆", folderName: "飲み物", purchasedAt: day(6, hour: 13)),
        ]
    }
}

// MARK: - View

/// メインビュー（履歴）
struct PurchaseRecordView: View {
    @State private var records: [PurchaseRecord] = PurchaseRecord.dummy()
    
    private let calendar = Calendar.current
    
    /// 日付ごとにグループ化し、新しい日付が上、同じ日の中も新しい順
    private var sections: [(day: Date, items: [PurchaseRecord])] {
        Dictionary(grouping: records) { calendar.startOfDay(for: $0.purchasedAt) }
            .map { (day: $0.key, items: $0.value.sorted { $0.purchasedAt > $1.purchasedAt }) }
            .sorted { $0.day > $1.day }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(sections, id: \.day) { section in
                    Section {
                        ForEach(section.items) { record in
                            PurchaseRow(record: record)
                        }
                    } header: {
                        Text(headerTitle(for: section.day))
                            .textCase(nil)
                            .font(.caption)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("購入履歴")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func headerTitle(for day: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日（E）"
        let text = formatter.string(from: day)
        return calendar.isDateInToday(day) ? "\(text)・今日" : text
    }
}

// MARK: - Row

/// 履歴の１つの見た目
struct PurchaseRow: View {
    let record: PurchaseRecord
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(record.name)
                .font(.body)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .layoutPriority(1)
            
            Spacer()
            
            Text(record.folderName)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}

// MARK: - Preview

#Preview {
    PurchaseRecordView()
}
