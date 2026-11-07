
import SwiftUI
import SwiftData

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
    @Environment(\.modelContext) private var modelContext
    @Environment(ToastCenter.self) private var toast
    @Query(FolderNode.rootsDescriptor) private var roots: [FolderNode]
    
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
    
    /// 追加：最大階層を超えるフォルダは作れない。編集：階層は変わらないので常に可
    private var canSubmit: Bool {
        switch mode {
        case .add(_, let parentLevel): return parentLevel < FolderLimit.maxDepth
        case .edit:                    return true
        }
    }
    
    /// 追加先と同じ階層にあるフォルダ（追加のときだけ使う）
    private var siblings: [FolderNode] {
        if case .add(let parent, _) = mode {
            return parent?.children ?? roots
        }
        return []
    }
    
    /// 追加する時の色の番号。並び順で自動
    private var nextTintIndex: Int {
        siblings.count % FolderTint.palette.count
    }
    
    /// アイコンなしのときのタイルの色。追加：並び順で自動、編集：今の色のまま
    private var tint: FolderTint {
        switch mode {
        case .add:
            return FolderTint.palette[nextTintIndex]
        case .edit(let node):
            return node.tint
        }
    }
    
    private var trimmedName: String { name.trimmingCharacters(in: .whitespaces) }
    
    /// 同じ親フォルダの中にある、ほかのフォルダ（追加：全員、編集：自分を除く）
    private var otherFolders: [FolderNode] {
        switch mode {
        case .add(let parent, _):
            return parent?.children ?? roots
        case .edit(let node):
            let all = node.parent?.children ?? roots
            return all.filter { $0.id != node.id }
        }
    }
    
    /// 同じ名前（完全一致）のフォルダが、すでにあるか
    private var isDuplicateName: Bool {
        !trimmedName.isEmpty && otherFolders.contains { $0.name == trimmedName }
    }
    
    // MARK: Body
    
    var body: some View {
        NavigationStack {
            Form {
                // 名前（左に選択中のイメージをプレビュー）
                Section {
                    HStack(spacing: 12) {
                        FolderImageView(
                            name: trimmedName.isEmpty ? "新" : trimmedName,
                            tint: tint,
                            customIcon: customIcon
                        )
                        HStack {
                            TextField("食品、日用品、ドラッグストア・・・", text: $name)
                            
                            Spacer()
                            
                            if isDuplicateName {
                                Text("既にあります")
                                    .foregroundStyle(.red)
                            }

                        }
                    }
                }
                
                // イメージ選択
                Section {
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
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        submit()
                        toast.show("保存しました", animation: .blur)
                    }) {
                        Image(systemName: "checkmark")
                    }
                    .fontWeight(.semibold)
                    .disabled(trimmedName.isEmpty || !canSubmit || isDuplicateName)
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
        guard !trimmedName.isEmpty, canSubmit, !isDuplicateName else { return }
        switch mode {
        case .add(let parent, _):
            // 並び順と色は、追加する前の兄弟フォルダの数・最大値から決める
            let nextOrder = (siblings.map(\.sortOrder).max() ?? -1) + 1
            let folder = FolderNode(
                name: trimmedName,
                tintIndex: nextTintIndex,
                customIcon: customIcon,
                sortOrder: nextOrder
            )
            modelContext.insert(folder)
            folder.parent = parent
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
        .modelContainer(PreviewData.container())
        .toastHost(ToastCenter())
        .tint(Color(red: 0.18, green: 0.55, blue: 0.37))
}

#Preview("編集") {
    let container = PreviewData.container()
    let first = try? container.mainContext.fetch(FolderNode.rootsDescriptor).first
    return Group {
        if let first {
            FolderFormView(mode: .edit(first))
        }
    }
    .modelContainer(container)
    .toastHost(ToastCenter())
    .tint(Color(red: 0.18, green: 0.55, blue: 0.37))
}
