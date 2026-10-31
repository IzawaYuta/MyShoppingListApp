
import SwiftUI

// MARK: - Folder options (階層付きの一覧)

/// 追加先フォルダの選択肢。level はフォルダの階層（1〜）
struct FolderOption: Identifiable {
    let node: FolderNode
    let level: Int
    var id: UUID { node.id }
    
    /// このフォルダにアイテムを入れられるか（1階層目は入れられない）
    var canHoldItems: Bool { level >= FolderLimit.itemMinLevel }
    
    /// 配下（子・孫）のうち、アイテムを入れられるフォルダの id
    var descendantDestinationIDs: [UUID] {
        Self.collect(node.children, level: level + 1)
    }
    
    private static func collect(_ nodes: [FolderNode], level: Int) -> [UUID] {
        nodes.flatMap { child in
            (level >= FolderLimit.itemMinLevel ? [child.id] : []) + collect(child.children, level: level + 1)
        }
    }
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

// MARK: - Multi select

/// 追加先フォルダを複数選択する行（開くとフォルダ一覧が出る）
/// selectedIDs には「アイテムを入れられるフォルダ（2階層目以降）」の id だけを入れる
struct FolderMultiSelectGroup: View {
    @Environment(FolderStore.self) private var store
    @Binding var selectedIDs: Set<UUID>
    @State private var isExpanded = false
    /// 開いている（子フォルダを表示している）フォルダ。最初はすべて畳んでおく
    @State private var expandedFolderIDs: Set<UUID> = []
    
    private var allOptions: [FolderOption] { store.flattenedOptions }
    
    /// 画面に表示するフォルダ。畳んでいる親フォルダの配下は含めない
    private var visibleOptions: [FolderOption] {
        func walk(_ nodes: [FolderNode], level: Int) -> [FolderOption] {
            nodes.flatMap { node -> [FolderOption] in
                var result = [FolderOption(node: node, level: level)]
                if expandedFolderIDs.contains(node.id) {
                    result += walk(node.children, level: level + 1)
                }
                return result
            }
        }
        return walk(store.roots, level: 1)
    }
    
    private var selectedOptions: [FolderOption] {
        allOptions.filter { $0.canHoldItems && selectedIDs.contains($0.id) }
    }
    
    /// 閉じている時に右側へ表示する文字（2件まで名前、それ以上は件数）
    private var summary: String {
        selectedOptions.count <= 2
        ? selectedOptions.map(\.node.name).joined(separator: "、")
        : "\(selectedOptions.count)件"
    }
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            ForEach(visibleOptions) { option in
                folderRow(option)
            }
        } label: {
            HStack {
                Text("追加先フォルダ")
                Spacer()
                Text(summary)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
    
    // MARK: State / action
    
    /// チェックの状態。1階層目は、配下がすべて選ばれている時だけチェック（一部選択の表示はしない）
    private func isChecked(_ option: FolderOption) -> Bool {
        if option.canHoldItems {
            return selectedIDs.contains(option.id)
        }
        let ids = option.descendantDestinationIDs
        return !ids.isEmpty && ids.allSatisfy { selectedIDs.contains($0) }
    }
    
    private func toggleSelection(_ option: FolderOption) {
        if option.canHoldItems {
            if selectedIDs.contains(option.id) {
                // 外すのは自分だけ（配下のチェックはそのまま残る）
                selectedIDs.remove(option.id)
            } else {
                // 選ぶと、自分と配下のすべてのフォルダにチェックが入る
                selectedIDs.insert(option.id)
                selectedIDs.formUnion(option.descendantDestinationIDs)
            }
        } else {
            // 1階層目：すべて選択済みなら全部外し、それ以外は全部選ぶ
            let ids = option.descendantDestinationIDs
            if isChecked(option) {
                selectedIDs.subtract(ids)
            } else {
                selectedIDs.formUnion(ids)
            }
        }
    }
    
    private func toggleExpansion(_ option: FolderOption) {
        if expandedFolderIDs.contains(option.id) {
            expandedFolderIDs.remove(option.id)
        } else {
            expandedFolderIDs.insert(option.id)
        }
    }
    
    // MARK: Row
    
    private func folderRow(_ option: FolderOption) -> some View {
        let checked = isChecked(option)
        let hasChildren = !option.node.children.isEmpty
        let isOpen = expandedFolderIDs.contains(option.id)
        // 配下にアイテムを入れられるフォルダがない1階層目は選べない
        let isDisabled = !option.canHoldItems && option.descendantDestinationIDs.isEmpty
        
        return HStack(spacing: 12) {
            // チェックと名前：タップで選択
            Button {
                toggleSelection(option)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: checked ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(checked ? Color.accentColor : Color.secondary)
                    Text(option.node.name)
                        .fontWeight(option.canHoldItems ? .regular : .semibold)
                        .foregroundStyle(.primary)
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(isDisabled)
            
            // 矢印：タップで子フォルダを開閉
            if hasChildren {
                Button {
                    withAnimation { toggleExpansion(option) }
                } label: {
                    Image(systemName: isOpen ? "chevron.down" : "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.leading, CGFloat(option.level - 1) * 20)   // 階層ごとにインデント
    }
}
