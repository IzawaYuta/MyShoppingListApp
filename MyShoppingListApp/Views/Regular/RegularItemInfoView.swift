
import SwiftUI

// MARK: - Model

enum RecurrenceFrequency: String, CaseIterable, Identifiable {
    case daily = "毎日"
    case weekly = "毎週"
    case biweekly = "隔週"
    case monthly = "毎月"
    case yearly = "毎年"
    
    var id: String { rawValue }
    
    /// 次の日付を求めるための Calendar 単位と間隔
    var step: (component: Calendar.Component, value: Int) {
        switch self {
        case .daily:    return (.day, 1)
        case .weekly:   return (.weekOfYear, 1)
        case .biweekly: return (.weekOfYear, 2)
        case .monthly:  return (.month, 1)
        case .yearly:   return (.year, 1)
        }
    }
}

struct RecurringItemDraft {
    var name = "牛乳"
    var quantity = "1本"
    var folder = "乳製品・卵"
    var startDate = Calendar.current.date(from: DateComponents(year: 2026, month: 11, day: 1)) ?? .now
    var frequency: RecurrenceFrequency = .weekly
    var hasEndDate = false
    var endDate = Calendar.current.date(from: DateComponents(year: 2027, month: 3, day: 31)) ?? .now
    var allowsDuplicate = false
    var isPriority = true
    var notifiesOnAdd = true
    var isActive = true
}

// MARK: - Dummy Data

private let sampleFolders = ["野菜・果物", "肉・魚", "乳製品・卵", "日用品", "飲み物", "調味料"]

// MARK: - Components

/// 丸型のチェックボックス行
struct CheckRow: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isOn ? Color.accentColor : Color.secondary)
                Text(title)
                    .foregroundStyle(.primary)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}

// MARK: - Screen

struct RegularItemInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft = RecurringItemDraft()
    
    var onSave: (RecurringItemDraft) -> Void = { _ in }
    
    var body: some View {
        NavigationStack {
            Form {
                // 名前・数量・フォルダ
                Section {
                    HStack {
                        TextField("アイテム名", text: $draft.name)
                        TextField("数量", text: $draft.quantity)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: 80)
                    }
                    Picker("追加先フォルダ", selection: $draft.folder) {
                        ForEach(sampleFolders, id: \.self) { Text($0) }
                    }
                }
                
                // 日付・頻度・終了日
                Section {
                    DatePicker("追加する日付", selection: $draft.startDate, displayedComponents: .date)
                    Picker("頻度", selection: $draft.frequency) {
                        ForEach(RecurrenceFrequency.allCases) { Text($0.rawValue).tag($0) }
                    }
                    Toggle("終了日を設定", isOn: $draft.hasEndDate)
                    if draft.hasEndDate {
                        DatePicker("終了日", selection: $draft.endDate,
                                   in: draft.startDate..., displayedComponents: .date)
                    }
                } footer: {
                    Text(nextDatesText)
                }
                
                // 重複・優先
                Section {
                    CheckRow(title: "重複して追加", isOn: $draft.allowsDuplicate)
                    CheckRow(title: "優先", isOn: $draft.isPriority)
                } footer: {
                    Text("「重複して追加」がオフの場合、未購入の同じアイテムがリストに残っていれば追加しません。")
                }
                
                // 通知・有効
                Section {
                    Toggle("追加時に通知", isOn: $draft.notifiesOnAdd)
                    Toggle("有効", isOn: $draft.isActive)
                } footer: {
                    Text("「有効」をオフにすると、削除せずに一時停止できます。")
                }
            }
            .navigationTitle("新規定期アイテム")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        onSave(draft)
                        dismiss()
                    }
                    .disabled(draft.name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .environment(\.locale, Locale(identifier: "ja_JP"))
    }
    
    // MARK: Next dates
    
    /// 設定内容から求めた、次回以降の追加予定日
    private var nextDatesText: String {
        let calendar = Calendar.current
        let step = draft.frequency.step
        var dates: [Date] = []
        var current = draft.startDate
        
        while dates.count < 3 {
            if draft.hasEndDate && current > draft.endDate { break }
            dates.append(current)
            guard let next = calendar.date(byAdding: step.component, value: step.value, to: current) else { break }
            current = next
        }
        
        guard !dates.isEmpty else { return "追加予定はありません" }
        let style = Date.FormatStyle(date: .abbreviated, time: .omitted,
                                     locale: Locale(identifier: "ja_JP"))
            .month(.defaultDigits).day(.defaultDigits)
        let text = dates.map { $0.formatted(style) }.joined(separator: "、")
        return "次回の追加予定：\(text)"
    }
}

// MARK: - Preview

#Preview {
    RegularItemInfoView()
        .tint(Color(red: 0.18, green: 0.55, blue: 0.37))
}
