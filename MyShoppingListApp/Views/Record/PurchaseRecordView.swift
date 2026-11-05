
import SwiftUI
import SwiftData

// MARK: - View

/// メインビュー（履歴）
struct PurchaseRecordView: View {
    @Query(sort: \PurchaseRecord.purchasedAt, order: .reverse)
    private var records: [PurchaseRecord]
    
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
        .modelContainer(PreviewData.container())
}
