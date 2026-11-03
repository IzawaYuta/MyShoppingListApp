
import SwiftUI

/// 現在地を示すパンくず（カテゴリー › 食品 › 野菜・果物 …）
/// 今いるフォルダ以外をタップすると、その階層まで戻る
struct BreadcrumbBarView: View {
    /// ホームから今いるフォルダまでの道筋（1階層目 → 今いるフォルダ）
    let routes: [FolderRoute]
    /// 「カテゴリー」（ホーム）をタップした時
    let onSelectHome: () -> Void
    /// 途中のフォルダをタップした時
    let onSelect: (FolderRoute) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                Button("カテゴリー", action: onSelectHome)
                    .font(.subheadline)
                
                ForEach(Array(routes.enumerated()), id: \.element) { index, route in
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    if index == routes.count - 1 {
                        // 今いるフォルダ：押せない。背景色と太字で目立たせる
                        Text(route.node.name)
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.15), in: RoundedRectangle(cornerRadius: 6))
                    } else {
                        Button(route.node.name) { onSelect(route) }
                            .font(.subheadline)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
        .defaultScrollAnchor(.trailing)   // 長い時は、今いるフォルダ側（右端）から表示する
    }
}
