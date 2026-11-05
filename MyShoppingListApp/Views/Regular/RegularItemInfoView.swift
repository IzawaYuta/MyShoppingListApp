
import SwiftUI
import SwiftData

// MARK: - Model

/// 下書きダミーデータ
struct RecurringItemDraft {
    var name = ""
    var quantity = ""
    var folderIDs: Set<UUID> = []
    var startDate = Calendar.current.startOfDay(for: .now)
    var frequency: RecurrenceFrequency = .weekly
    var hasEndDate = false
    var endDate = Calendar.current.startOfDay(for: .now)
    var allowsDuplicate = false
    var isPriority = false
    var notifiesOnAdd = true
    var isActive = true
}

// MARK: - Components

/// 丸型のチェックボックス行（再利用）
struct CheckRow: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        Button {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                isOn.toggle()
            }
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
    }
}

// MARK: - Screen

/// メインビュー（定期アイテム追加画面）
struct RegularItemInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ToastCenter.self) private var toast
    
    @State private var draft: RecurringItemDraft
    @State private var showCancelAlert = false
    @State private var pendingActive: Bool?
    @State private var showActiveAlert = false
    
    let title: String
    let isEditing: Bool
    var onSave: (RecurringItemDraft) -> Void
    
    init(draft: RecurringItemDraft = RecurringItemDraft(),
         title: String = "定期アイテム登録",
         isEditing: Bool = false,
         onSave: @escaping (RecurringItemDraft) -> Void = { _ in }) {
        _draft = State(initialValue: draft)
        self.title = title
        self.isEditing = isEditing
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // 名前・数量・フォルダ
                Section {
                    HStack {
                        TextField("アイテム名", text: $draft.name)
                        if draft.isPriority {
                            Image(systemName: "exclamationmark")
                                .bold()
                                .foregroundStyle(Color.red)
                        }
                    }
                    FolderMultiSelectGroup(selectedIDs: $draft.folderIDs)
                }
                
                // 日付・頻度・終了日
                Section {
                    DatePicker("開始日", selection: $draft.startDate, displayedComponents: .date)
                    Toggle("終了日を設定", isOn: $draft.hasEndDate)
                    if draft.hasEndDate {
                        DatePicker("終了日", selection: $draft.endDate,
                                   in: draft.startDate..., displayedComponents: .date)
                    }
                    Picker("頻度", selection: $draft.frequency) {
                        ForEach(RecurrenceFrequency.allCases) { Text($0.title).tag($0) }
                    }
                } footer: {
                    Text(nextDatesText)
                }
                
                // 重複・優先
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        CheckRow(title: "重複して追加", isOn: $draft.allowsDuplicate)
                        Text("オフの場合、同じアイテムがすでにあると追加されません。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 34)
                    }
                    .padding(.vertical, 2)
                    
                    CheckRow(title: "優先", isOn: $draft.isPriority)
                }
                
                // 通知・有効
                // TODO: 将来の新規機能
//                Section {
//                    Toggle("追加時に通知", isOn: $draft.notifiesOnAdd)
//                }
                // 有効（編集の時だけ）
                Section {
                    Toggle("無効にする", isOn: Binding(
                        get: { draft.isActive },
                        set: { newValue in
                            // すぐには変えず、確認のアラートを出す
                            pendingActive = newValue
                            showActiveAlert = true
                        }
                    ))
                    .alert(
                        pendingActive == false ? "有効にしますか？" : "無効にしますか？",
                        isPresented: $showActiveAlert
                    ) {
                        Button("キャンセル", role: .cancel) { pendingActive = nil }
                        Button(pendingActive == false ? "有効にする" : "無効にする") {
                            if let newValue = pendingActive {
                                draft.isActive = newValue
                            }
                            pendingActive = nil
                        }
                    } message: {
                        Text(pendingActive == false
                             ? "指定した日に、自動で追加されます。"
                             : "削除はされません。\n自動追加が無効になります。")
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        showCancelAlert = true
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        onSave(draft)
                        dismiss()
                        toast.show("保存しました", animation: .blur)
                    }) {
                        Image(systemName: "checkmark")
                    }
                    .disabled(draft.name.trimmingCharacters(in: .whitespaces).isEmpty || draft.folderIDs.isEmpty)
                }
            }
        }
        .environment(\.locale, Locale(identifier: "ja_JP"))
        .alert("入力内容を破棄しますか？", isPresented: $showCancelAlert) {
            Button("キャンセル", role: .cancel) { }
            Button("破棄", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("入力した内容は保存されません。")
        }
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
        return "追加予定：\(text)"
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RegularItemInfoView()
    }
    .modelContainer(PreviewData.container())
    .toastHost(ToastCenter())
    .tint(Color(red: 0.18, green: 0.55, blue: 0.37))
}
