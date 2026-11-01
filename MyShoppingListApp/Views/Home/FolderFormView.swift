
import SwiftUI

// MARK: - Mode

/// フォルダ画面の使い方（追加 or 編集）
enum FolderFormMode {
    /// 追加。parent は追加先の親フォルダ（nil なら最上位）、level は親フォルダの階層（最上位なら 0）
    case add(parent: FolderNode?, level: Int)
    /// 編集。編集するフォルダ
    case edit(FolderNode)
}

// MARK: - Screen

/// フォルダの追加・編集画面（共通）
struct FolderFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(FolderStore.self) private var store
    
    private let mode: FolderFormMode
    
    // 入力中の内容（「追加」「保存」を押すまでは、フォルダに反映しない）
    @State private var name: String
    @State private var customIcon: CustomIconFolder?
    
    init(mode: FolderFormMode) {
        self.mode = mode
        switch mode {
        case .add:
            _name = State(initialValue: "")
            _customIcon = State(initialValue: nil)
        case .edit(let node):
            _name = State(initialValue: node.name)
            _customIcon = State(initialValue: node.customIcon)
        }
    }
    
    private let columns = [GridItem(.adaptive(minimum: 56), spacing: 12)]
    
    // MARK: Mode ごとの違い
    
    private var title: String {
        switch mode {
        case .add:  return "新規フォルダ"
        case .edit: return "フォルダを編集"
        }
    }
    
    private var confirmTitle: String {
        switch mode {
        case .add:  return "追加"
        case .edit: return "保存"
        }
    }
    
    /// 追加：最大階層を超えるフォルダは作れない。編集：階層は変わらないので常に可
    private var canSubmit: Bool {
        switch mode {
        case .add(_, let parentLevel): return parentLevel < FolderLimit.maxDepth
        case .edit:                    return true
        }
    }
    
    /// アイコンなしのときのタイルの色。追加：並び順で自動、編集：今の色のまま
    private var tint: FolderTint {
        switch mode {
        case .add(let parent, _):
            let siblingCount = parent?.children.count ?? store.roots.count
            return FolderTint.palette[siblingCount % FolderTint.palette.count]
        case .edit(let node):
            return node.tint
        }
    }
    
    private var trimmedName: String { name.trimmingCharacters(in: .whitespaces) }
    
    /// プレビュー表示用の仮フォルダ（名前の頭文字と選択中のイメージを反映）
    private var previewNode: FolderNode {
        FolderNode(name: trimmedName.isEmpty ? "新" : trimmedName, tint: tint, customIcon: customIcon)
    }
    
    // MARK: Body
    
    var body: some View {
        NavigationStack {
            Form {
                // 名前（左に選択中のイメージをプレビュー）
                Section {
                    HStack(spacing: 12) {
                        FolderImageView(node: previewNode)
                        TextField("フォルダ名", text: $name)
                    }
                }
                
                // イメージ選択
                Section("イメージ") {
                    iconCell(nil)
                    
                    ForEach(FolderIconCategory.allCases) { category in
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(category.icons) { icon in
                                iconCell(icon)
                            }
                        }
                        .padding(.top, 12)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(confirmTitle) { submit() }
                        .fontWeight(.semibold)
                        .disabled(trimmedName.isEmpty || !canSubmit)
                }
            }
        }
    }
    
    // MARK: Image cell
    
    /// cellIcon が nil のセルは「画像なし」（頭文字タイル）
    private func iconCell(_ cellIcon: CustomIconFolder?) -> some View {
        let isSelected = customIcon == cellIcon
        return Button {
            customIcon = cellIcon
        } label: {
            Group {
                if let cellIcon {
                    cellIcon.image
                        .resizable()
                        .scaledToFit()
                        .background(Color.white)
                } else {
                    Text("Aa")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(tint.foreground)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(tint.background)
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.accentColor, lineWidth: isSelected ? 3 : 0)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: Action
    
    private func submit() {
        guard !trimmedName.isEmpty, canSubmit else { return }
        switch mode {
        case .add(let parent, _):
            let folder = FolderNode(name: trimmedName, tint: tint, customIcon: customIcon)
            if let parent {
                parent.children.append(folder)
            } else {
                store.roots.append(folder)
            }
        case .edit(let node):
            node.name = trimmedName
            node.customIcon = customIcon
        }
        dismiss()
    }
}

// MARK: - Preview

#Preview("追加") {
    FolderFormView(mode: .add(parent: nil, level: 0))
        .environment(FolderStore())
        .tint(Color(red: 0.18, green: 0.55, blue: 0.37))
}

#Preview("編集") {
    let store = FolderStore()
    return FolderFormView(mode: .edit(store.roots[0]))
        .environment(store)
        .tint(Color(red: 0.18, green: 0.55, blue: 0.37))
}
