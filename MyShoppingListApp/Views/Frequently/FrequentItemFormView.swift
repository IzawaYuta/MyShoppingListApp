
import SwiftUI
import SwiftData

/// よく買うものの登録・編集画面
struct FrequentItemFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    /// 編集するアイテム。nil のときは新規登録
    private let item: FrequentItem?
    //    private let onSave: (FrequentItem) -> Void
    
    // 入力中の内容（「保存」を押すまでは反映しない）
    @State private var name: String
    @State private var isPriority: Bool
    @State private var folderIDs: Set<UUID>
    
    init(item: FrequentItem? = nil) {
        self.item = item
        _name = State(initialValue: item?.name ?? "")
        _isPriority = State(initialValue: item?.isPriority ?? false)
        _folderIDs = State(initialValue: Set(item?.folderIDs ?? []))
    }
    
    private var trimmedName: String { name.trimmingCharacters(in: .whitespaces) }
    
    var body: some View {
        NavigationStack {
            Form {
                // 名前・優先
                Section {
                    HStack {
                        TextField("アイテム名", text: $name)
                            .accessibilityIdentifier("itemNameField")   
                        if isPriority {
                            Image(systemName: "exclamationmark")
                                .bold()
                                .foregroundStyle(Color.red)
                        }
                    }
                    CheckRow(title: "優先", isOn: $isPriority)   // RegularItemInfoView.swift のものを使用
                }
                
                // 追加先フォルダ（複数選択）
                Section {
                    FolderMultiSelectGroup(selectedIDs: $folderIDs)
                } footer: {
                    Text("登録したアイテムは、「よく買うもの」から選んで、まとめてリストに追加できます。")
                }
            }
            .navigationTitle(item == nil ? "よく買うものを登録" : "よく買うものを編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                    }
                    .accessibilityIdentifier("itemCloseButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        save()
                    }) {
                        Image(systemName: "checkmark")
                    }
                    .accessibilityIdentifier("itemSaveButton")   
                    .disabled(trimmedName.isEmpty || folderIDs.isEmpty)
                }
            }
        }
    }
    
    private func save() {
        if let item {
            // 編集：元のアイテムに反映する
            item.name = trimmedName
            item.isPriority = isPriority
            item.folderIDs = Array(folderIDs)
        } else {
            // 新規登録
            modelContext.insert(FrequentItem(
                name: trimmedName,
                isPriority: isPriority,
                folderIDs: Array(folderIDs)
            ))
        }
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    FrequentItemFormView()
        .modelContainer(PreviewData.container())
        .tint(Color(red: 0.18, green: 0.55, blue: 0.37))
}
