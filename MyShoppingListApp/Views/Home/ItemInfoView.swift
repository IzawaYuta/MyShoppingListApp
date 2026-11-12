
import SwiftUI
import SwiftData

// MARK: - Screen

/// メインビュー（アイテム追加画面）
struct ItemInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ToastCenter.self) private var toast
    
    @Query(FolderNode.rootsDescriptor) private var roots: [FolderNode]
    
    @State private var name = ""
    @State private var quantity = ""
    @State private var isPriority = false
    @State private var selectedFolderIDs: Set<UUID>
    
    /// 続けて登録するか（最後に選んだ状態を、アプリを閉じても覚えておく）
    @AppStorage("continuousAddEnabled") private var continuousAdd = false
    /// 名前の入力欄に、カーソルを戻すために使う
    @FocusState private var isNameFocused: Bool
    
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
                            .focused($isNameFocused)
                            .accessibilityIdentifier("itemNameField")  
                        if isPriority {
                            Image(systemName: "exclamationmark")
                                .bold()
                                .foregroundStyle(Color.red)
                        }
                    }
                    CheckRow(title: "優先", isOn: $isPriority)   // RecurringItemFormView.swift のものを使用
                }
                
                // 連続登録（オンのとき、追加しても画面を閉じない）
                Section {
                    Toggle("続けて登録", isOn: $continuousAdd)
                } footer: {
                    Text("オンのとき、追加しても画面を閉じずに、続けて登録できます。")
                }
                
                // 追加先フォルダ（複数選択）
                Section {
                    FolderMultiSelectGroup(selectedIDs: $selectedFolderIDs)
                }
                
                // 定期アイテムとして登録（登録画面へ遷移）
//                Section {
//                    NavigationLink {
//                        RegularItemInfoView(draft: recurringDraft) { saved in
//                            RecurringItemRunner.register(saved, in: modelContext)
//                            dismiss()   // 登録したら、新規アイテムの画面も閉じる
//                        }
//                    } label: {
//                        Text("定期アイテムとして登録")
//                            .foregroundStyle(Color.accentColor)
//                    }
//                }
            }
            .navigationTitle("購入アイテム")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        add()
                    }) {
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                    }
                    .accessibilityIdentifier("itemSaveButton")  
                    .disabled(!canAdd)
                }
            }
        }
        .toastHost(toast)
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
        for option in roots.flattenedOptions
        where option.canHoldItems && selectedFolderIDs.contains(option.id) {
            option.node.addItem(name: trimmed, isPriority: isPriority, in: modelContext)
        }
        
        if continuousAdd {
            // 続けて登録：名前と優先を空にして、追加先は残す。キーボードを出したまま、次を入力できる
            // トーストは、✓ボタンに重ならないよう、画面の下に出す
            toast.show("追加しました", animation: .bottom)
            name = ""
            isPriority = false
            isNameFocused = true
        } else {
            // 単発：追加して閉じる。トーストは、閉じたあとの一覧の画面で出る
            toast.show("追加しました")
            dismiss()
        }
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
    let container = PreviewData.container()
    let first = try? container.mainContext.fetch(FolderNode.rootsDescriptor).first
    return ItemInfoView(currentFolder: first)
        .modelContainer(container)
        .toastHost(ToastCenter())
        .tint(Color(red: 0.18, green: 0.55, blue: 0.37))
}
