
import SwiftUI

/// フォルダのアイコンを選ぶグリッド（フォルダの追加画面と編集画面で共通）
struct FolderIconPicker: View {
    @Binding var icon: CustomIconFolder?   // nil = アイコンなし（頭文字タイル）
    let tint: FolderTint
    
    private let columns = [GridItem(.adaptive(minimum: 56), spacing: 12)]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            cell(nil)
            ForEach(CustomIconFolder.allCases) { cell($0) }
        }
        .padding(.vertical, 6)
    }
    
    /// cellIcon が nil のセルは「アイコンなし」（頭文字タイル）
    private func cell(_ cellIcon: CustomIconFolder?) -> some View {
        let isSelected = icon == cellIcon
        return Button {
            icon = cellIcon
        } label: {
            Color.clear
                .frame(width: 56, height: 56)
                .overlay {
                    if let cellIcon {
                        cellIcon.image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white)
                    } else {
                        Text("Aa")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(tint.foreground)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(tint.background)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.accentColor, lineWidth: isSelected ? 3 : 0)
                )
        }
        .buttonStyle(.plain)
    }
}
