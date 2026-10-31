
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
    
    private enum CheckState { case on, partial, off }
    
    private var options: [FolderOption] { store.flattenedOptions }
    
    private var selectedOptions: [FolderOption] {
        options.filter { $0.canHoldItems && selectedIDs.contains($0.id) }
    }
    
    /// 閉じている時に右側へ表示する文字（2件まで名前、それ以上は件数）
    private var summary: String {
        selectedOptions.count <= 2
        ? selectedOptions.map(\.node.name).joined(separator: "、")
        : "\(selectedOptions.count)件"
    }
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            ForEach(options) { option in
                folderRow(option)
            }
            Text("1階層目のフォルダを選ぶと、配下のフォルダがすべて選択されます。")
                .font(.footnote)
                .foregroundStyle(.secondary)
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
    
    private func state(of option: FolderOption) -> CheckState {
        if option.canHoldItems {
            return selectedIDs.contains(option.id) ? .on : .off
        }
        // 1階層目：配下の選択状況から決める
        let ids = option.descendantDestinationIDs
        let count = ids.filter { selectedIDs.contains($0) }.count
        if count == 0 { return .off }
        return count == ids.count ? .on : .partial
    }
    
    private func toggle(_ option: FolderOption) {
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
            if state(of: option) == .on {
                selectedIDs.subtract(ids)
            } else {
                selectedIDs.formUnion(ids)
            }
        }
    }
    
    // MARK: Row
    
    private func folderRow(_ option: FolderOption) -> some View {
        let state = state(of: option)
        let imageName: String = {
            switch state {
            case .on:      return "checkmark.circle.fill"
            case .partial: return "minus.circle.fill"
            case .off:     return "circle"
            }
        }()
        // 配下にアイテムを入れられるフォルダがない1階層目は選べない
        let isDisabled = !option.canHoldItems && option.descendantDestinationIDs.isEmpty
        
        return Button {
            toggle(option)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: imageName)
                    .font(.title3)
                    .foregroundStyle(state == .off ? Color.secondary : Color.accentColor)
                Text(option.node.name)
                    .fontWeight(option.canHoldItems ? .regular : .semibold)
                    .foregroundStyle(.primary)
                Spacer()
            }
            .padding(.leading, CGFloat(option.level - 1) * 20)   // 階層ごとにインデント
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}
