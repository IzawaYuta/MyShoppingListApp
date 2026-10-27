
import SwiftUI

// MARK: - Models

struct Folder: Identifiable {
    let id = UUID()
    let name: String
    let initial: String   // 仮のImage（実際の画像に差し替える場合は imageName などに変更）
    let count: Int
    let background: Color
    let foreground: Color
}

struct ShoppingItem: Identifiable {
    let id = UUID()
    var name: String
    var quantity: String
    var isDone: Bool = false
}

// MARK: - Dummy Data

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

extension ShoppingItem {
    static let samples: [ShoppingItem] = [
        ShoppingItem(name: "牛乳", quantity: "1本"),
        ShoppingItem(name: "食パン", quantity: "1袋"),
        ShoppingItem(name: "卵", quantity: "10個", isDone: true),
        ShoppingItem(name: "ヨーグルト", quantity: "2個"),
        ShoppingItem(name: "ほうれん草", quantity: "1束", isDone: true),
        ShoppingItem(name: "にんじん", quantity: "3本"),
        ShoppingItem(name: "鶏むね肉", quantity: "300g"),
        ShoppingItem(name: "バナナ", quantity: "1房")
    ]
}

// MARK: - Rows

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
            
            Text("\(folder.count)")
                .foregroundStyle(.secondary)
        }
    }
}

struct ItemRow: View {
    @Binding var item: ShoppingItem
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                item.isDone.toggle()
            } label: {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(item.isDone ? Color.accentColor : Color.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(item.isDone ? "購入済み" : "未購入")
            
            Text(item.name)
                .strikethrough(item.isDone)
                .foregroundStyle(item.isDone ? .secondary : .primary)
            
            Spacer()
            
            Text(item.quantity)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Screen

struct FolderItemView: View {
    @State private var folders = Folder.samples
    @State private var items = ShoppingItem.samples
    
    var body: some View {
        List {
            Section("フォルダ") {
                ForEach(folders) { folder in
                    NavigationLink {
                        Text(folder.name) // 遷移先（ダミー）
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
                .accessibilityLabel("追加")
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
