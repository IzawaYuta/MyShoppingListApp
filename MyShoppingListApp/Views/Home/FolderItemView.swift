import SwiftUI

// MARK: - Rows

/// 「自動追加」の印。説明の文章の中や、アイテム名の横で使う
struct AutoAddedBadge: View {
    /// 正方形の一辺。文字の大きさの設定に合わせて変わる
    @ScaledMetric(relativeTo: .caption2) private var size: CGFloat = 20
    private let textSize: CGFloat = 11
    
    var body: some View {
        Text("自")
            .font(.system(size: textSize))
            .foregroundStyle(.black)
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.gray.opacity(0.2))
            )
    }
}

/// アイテムの横線のアニメーション
struct AnimatedStrikethrough: View {
    let isDone: Bool
    
    @State private var progress: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let y = geometry.size.height / 2
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: geometry.size.width, y: y))
            }
            .trim(from: 0, to: progress)
            .stroke(.secondary, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
            .onChange(of: isDone) { _, newValue in
                withAnimation(.easeInOut(duration: 0.4)) {
                    progress = newValue ? 1 : 0
                }
            }
            .onAppear {
                progress = isDone ? 1 : 0
            }
        }
        .allowsHitTesting(false)
    }
}

/// アイテムの見た目（ShoppingItem は DataModels.swift のもの）
struct ItemRow: View {
    let item: ShoppingItem
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(item.isDone ? Color.accentColor : Color.secondary)
            
            Text(item.name)
                .foregroundStyle(item.isDone ? .secondary : .primary)
                .overlay {
                    AnimatedStrikethrough(isDone: item.isDone)
                }
            
            // 定期アイテムの自動追加で入ったもの
            if item.isAutoAdded {
                AutoAddedBadge()
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
            item.toggleDone()
        }
    }
}
