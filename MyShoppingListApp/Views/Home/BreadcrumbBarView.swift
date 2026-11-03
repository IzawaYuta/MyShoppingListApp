
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
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    Button("カテゴリー", action: onSelectHome)
                        .font(.subheadline)
                        .buttonStyle(.borderless)      // ← 追加：行全体に反応しないようにする
                    
                    ForEach(Array(routes.enumerated()), id: \.element) { index, route in
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        if index == routes.count - 1 {
                            Text(route.node.name)
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.accentColor.opacity(0.15), in: RoundedRectangle(cornerRadius: 6))
                                .id("current")          // ← 追加：今いるフォルダの目印
                        } else {
                            Button(route.node.name) { onSelect(route) }
                                .font(.subheadline)
                                .buttonStyle(.borderless)   // ← 追加
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            }
            // 長くて収まらない時だけ、今いるフォルダ（右端）が見える位置までスクロールする
            .onAppear { proxy.scrollTo("current", anchor: .trailing) }
        }
    }
}
