
import SwiftUI

// MARK: - Folder options (階層付きの一覧)

/// 追加先フォルダの選択肢。level はフォルダの階層（1〜）
struct FolderOption: Identifiable {
    let node: FolderNode
    let level: Int
    var id: UUID { node.id }
}

extension FolderStore {
    /// 全フォルダを、階層順（親 → 子）に並べた一覧にする
    var flattenedOptions: [FolderOption] {
        func walk(_ nodes: [FolderNode], level: Int) -> [FolderOption] {
            nodes.flatMap { [FolderOption(node: $0, level: level)] + walk($0.children, level: level + 1) }
        }
        return walk(roots, level: 1)
    }
}

// MARK: - Screen

struct ItemInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(FolderStore.self) private var store
    
    @State private var name = ""
    @State private var quantity = ""
    @State private var isPriority = false
    @State private var selectedFolderIDs: Set<UUID>
    @State private var isFolderListExpanded = false
    
    /// currentFolder: 今いるフォルダ。最初から選択状態にする
    init(currentFolder: FolderNode? = nil) {
        _selectedFolderIDs = State(initialValue: currentFolder.map { [$0.id] } ?? [])
    }
    
    private var options: [FolderOption] { store.flattenedOptions }
    
    private var selectedNames: String {
        options.filter { selectedFolderIDs.contains($0.id) }
            .map(\.node.name)
            .joined(separator: "、")
    }
    
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
                        TextField("数量", text: $quantity)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: 80)
                    }
                    CheckRow(title: "優先", isOn: $isPriority)   // RecurringItemFormView.swift のものを使用
                }
                
                // 追加先フォルダ（複数選択）
                Section {
                    DisclosureGroup(isExpanded: $isFolderListExpanded) {
                        ForEach(options) { option in
                            folderRow(option)
                        }
                    } label: {
                        HStack {
                            Text("追加先フォルダ")
                            Spacer()
                            Text(selectedNames)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
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
    
    // MARK: Folder row
    
    private func folderRow(_ option: FolderOption) -> some View {
        let isSelected = selectedFolderIDs.contains(option.id)
        return Button {
            if isSelected {
                selectedFolderIDs.remove(option.id)
            } else {
                selectedFolderIDs.insert(option.id)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                Text(option.node.name)
                    .foregroundStyle(.primary)
                Spacer()
            }
            .padding(.leading, CGFloat(option.level - 1) * 20)   // 階層ごとにインデント
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
    
    // MARK: Actions
    
    /// 選択したすべてのフォルダに、同じアイテムを追加する
    private func add() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        for option in options where selectedFolderIDs.contains(option.id) {
            option.node.items.append(
                ShoppingItem(name: trimmed, quantity: quantity, isPriority: isPriority)
            )
        }
        dismiss()
    }
    
    /// 定期アイテム登録画面に引き継ぐ内容
    private var recurringDraft: RecurringItemDraft {
        var draft = RecurringItemDraft()
        draft.name = name
        draft.quantity = quantity
        draft.isPriority = isPriority
        if let first = options.first(where: { selectedFolderIDs.contains($0.id) }) {
            draft.folder = first.node.name   // 定期側は今のところ1フォルダのみ
        }
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
