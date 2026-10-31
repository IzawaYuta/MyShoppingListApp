
import SwiftUI

// MARK: - Screen

/// メインビュー（アイテム追加画面）
struct ItemInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(FolderStore.self) private var store
    
    @State private var name = ""
    @State private var quantity = ""
    @State private var isPriority = false
    @State private var selectedFolderIDs: Set<UUID>
    
    /// currentFolder: 今いるフォルダ。最初から選択状態にする
    init(currentFolder: FolderNode? = nil) {
        _selectedFolderIDs = State(initialValue: currentFolder.map { [$0.id] } ?? [])
    }
    
    /// アイテム追加ボタンを押せるか
    private var canAdd: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && !selectedFolderIDs.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // 名前・数量・優先
                Section {
                    HStack {
                        TextField("アイテム名", text: $name)
                        if isPriority {
                            Image(systemName: "exclamationmark")
                                .bold()
                                .foregroundStyle(Color.red)
                        }
                    }
                    CheckRow(title: "優先", isOn: $isPriority)   // RecurringItemFormView.swift のものを使用
                }
                
                // 追加先フォルダ（複数選択）
                Section {
                    FolderMultiSelectGroup(selectedIDs: $selectedFolderIDs)
                }
                
                // 定期アイテムとして登録（登録画面へ遷移）
                Section {
                    NavigationLink {
                        RegularItemInfoView(draft: recurringDraft)
                    } label: {
                        Text("定期アイテムとして登録")
                            .foregroundStyle(Color.accentColor)
                    }
                }
            }
            .navigationTitle("新規アイテム")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") { add() }
                        .fontWeight(.semibold)
                        .disabled(!canAdd)
                }
            }
        }
    }
    
//    // MARK: Folder row
//    
//    /// 「追加先フォルダ」を開いた時に表示される、フォルダ1行分の見た目と、タップした時の動きを作る関数
//    private func folderRow(_ option: FolderOption) -> some View {
//        let isSelected = selectedFolderIDs.contains(option.id)
//        return Button {
//            if isSelected {
//                selectedFolderIDs.remove(option.id)
//            } else {
//                selectedFolderIDs.insert(option.id)
//            }
//        } label: {
//            HStack(spacing: 12) {
//                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
//                    .font(.title3)
//                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
//                Text(option.node.name)
//                    .foregroundStyle(.primary)
//                Spacer()
//            }
//            .padding(.leading, CGFloat(option.level - 1) * 20)   // 階層ごとにインデント
//            .contentShape(Rectangle())
//        }
//        .buttonStyle(.plain)
//    }
    
    // MARK: Actions
    
    /// 選択したすべてのフォルダに、同じアイテムを追加する
    private func add() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        for option in store.flattenedOptions where option.canHoldItems && selectedFolderIDs.contains(option.id) {
            
        }
        dismiss()
    }
    
    /// 定期アイテム登録画面に引き継ぐ内容
    private var recurringDraft: RecurringItemDraft {
        var draft = RecurringItemDraft()
        draft.name = name
        draft.quantity = quantity
        draft.isPriority = isPriority
        draft.folderIDs = selectedFolderIDs
        return draft
    }
}

// MARK: - Preview

#Preview {
    let store = FolderStore()
    return ItemInfoView(currentFolder: store.roots.first)
        .environment(store)
        .tint(Color(red: 0.18, green: 0.55, blue: 0.37))
}
