
import SwiftUI

// MARK: - Models

/// フォルダモデル
struct Folder: Identifiable {
    let id = UUID()
    let name: String
    let initial: String   // 仮のImage（実際の画像に差し替える場合は imageName などに変更）
    let count: Int
    let background: Color
    let foreground: Color
}

/// アイテムモデル
struct ShoppingItem: Identifiable {
    let id = UUID()
    var name: String
    var isPriority: Bool = false
    var isDone: Bool = false
}

// MARK: - Dummy Data

/// フォルダダミーデータ
extension Folder {
    static let samples: [Folder] = [
        Folder(name: "野菜・果物", initial: "菜", count: 19,
               background: Color(red: 0.89, green: 0.96, blue: 0.84),
               foreground: Color(red: 0.25, green: 0.48, blue: 0.11)),
        Folder(name: "肉・魚", initial: "肉", count: 9,
               background: Color(red: 0.98, green: 0.89, blue: 0.89),
               foreground: Color(red: 0.69, green: 0.23, blue: 0.23)),
        Folder(name: "乳製品・卵", initial: "乳", count: 6,
               background: Color(red: 1.00, green: 0.95, blue: 0.81),
               foreground: Color(red: 0.54, green: 0.42, blue: 0.00))
    ]
}

/// アイテムダミーデータ
extension ShoppingItem {
    static let samples: [ShoppingItem] = [
        ShoppingItem(name: "牛乳"),
        ShoppingItem(name: "食パン"),
        ShoppingItem(name: "卵", isDone: true),
        ShoppingItem(name: "ヨーグルト"),
        ShoppingItem(name: "ほうれん草", isDone: true),
        ShoppingItem(name: "にんじん"),
        ShoppingItem(name: "鶏むね肉"),
        ShoppingItem(name: "バナナ")
    ]
}

// MARK: - Rows

/// フォルダの見た目
struct FolderRow: View {
    let folder: Folder
    
    var body: some View {
        HStack(spacing: 12) {
            Text(folder.initial)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(folder.foreground)
                .frame(width: 36, height: 36)
                .background(folder.background, in: RoundedRectangle(cornerRadius: 8))
            
            Text(folder.name)
            
            Spacer()
        }
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

/// アイテムの見た目
struct ItemRow: View {
    @Binding var item: ShoppingItem
    
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
            item.isDone.toggle()
        }
    }
}

// MARK: - Screen

/// メインビュー
struct FolderItemView: View {
    @State private var folders = Folder.samples
    @State private var items = ShoppingItem.samples
    
    var body: some View {
        List {
            Section("フォルダ") {
                ForEach(folders) { folder in
                    NavigationLink {
                        Text(folder.name)
                    } label: {
                        FolderRow(folder: folder)
                    }
                }
            }
            
            Section("買うもの") {
                ForEach($items) { $item in
                    ItemRow(item: $item)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("食品")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // アイテム追加画面を表示
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        FolderItemView()
    }
    .tint(Color(red: 0.18, green: 0.55, blue: 0.37))
}
