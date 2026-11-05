import SwiftUI

// MARK: - Rows

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
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
            item.toggleDone()
        }
    }
}
