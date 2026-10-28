
import SwiftUI

// MARK: - Image catalog

/// フォルダに選べるイメージの一覧（Assets.xcassets に入れた画像の名前）
/// ※ 実際に追加した画像の名前に置き換えてください
enum FolderImageCatalog {
    static let names: [String] = [
        "apple",
        // "folder_meat",
        // "folder_dairy",
        // "folder_daily",
        // "folder_drink",
        // "folder_seasoning",
    ]
}

// MARK: - Screen

struct FolderAddView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(FolderStore.self) private var store
    
    /// 追加先の親フォルダ。nil のときは最上位（カテゴリー）に追加する
    private let parent: FolderNode?
    /// 親フォルダの階層（最上位なら 0）
    private let parentLevel: Int
    
    @State private var name = ""
    @State private var customIcon: CustomIconFolder?
    
    init(parent: FolderNode? = nil, level parentLevel: Int = 0) {
        self.parent = parent
        self.parentLevel = parentLevel
    }
    
    private let columns = [GridItem(.adaptive(minimum: 56), spacing: 12)]
    
    private var trimmedName: String { name.trimmingCharacters(in: .whitespaces) }
    
    /// 最大階層を超えるフォルダは作れない
    private var canCreate: Bool { parentLevel < FolderLimit.maxDepth }
    
    private var siblingCount: Int { parent?.children.count ?? store.roots.count }
    
    private var tint: FolderTint {
        FolderTint.palette[siblingCount % FolderTint.palette.count]
    }
    
    /// プレビュー表示用の仮フォルダ（名前の頭文字と選択中のイメージを反映）
    private var previewNode: FolderNode {
        FolderNode(name: trimmedName.isEmpty ? "新" : trimmedName, tint: tint, customIcon: customIcon)
    }
    
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
                    LazyVGrid(columns: columns, spacing: 12) {
                        iconCell(nil)
                        ForEach(CustomIconFolder.allCases) { iconCell($0) }
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("新規フォルダ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") { add() }
                        .fontWeight(.semibold)
                        .disabled(trimmedName.isEmpty || !canCreate)
                }
            }
        }
    }
    
    // MARK: Image cell
    
    /// name が nil のセルは「画像なし」（頭文字タイル）
    private func iconCell(_ cellIcon: CustomIconFolder?) -> some View {
        let isSelected = customIcon == cellIcon
        return Button {
            customIcon = cellIcon
        } label: {
            Group {
                if let cellIcon {
                    cellIcon.image.resizable().scaledToFit()
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
    
    private func add() {
        guard !trimmedName.isEmpty, canCreate else { return }
        let folder = FolderNode(name: trimmedName, tint: tint, customIcon: customIcon)
        if let parent {
            parent.children.append(folder)
        } else {
            store.roots.append(folder)
        }
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    FolderAddView()
        .environment(FolderStore())
        .tint(Color(red: 0.18, green: 0.55, blue: 0.37))
}
