import SwiftUI

/// データがなくて、リストを表示できない時に出す画面（共通）
/// 「イメージ」「タイトル」「説明文」「追加ボタン」を、画面ごとに変えて使う
/// ※ SwiftUI にすでに EmptyView があるため、名前は EmptyStateView にしている
struct EmptyStateView: View {
    private let illustration: AnyView
    private let title: String
    private let message: String?
    private let buttonTitle: String?
    private let buttonSystemImage: String?
    private let action: (() -> Void)?
    /// ボタンを押すと開くメニューの中身（nil なら、普通のボタン）
    private let menuItems: AnyView?
    
    // MARK: - Init
    
    /// イメージを自由に作る（Image 以外の View も使える）
    init<Illustration: View>(
        title: String,
        message: String? = nil,
        buttonTitle: String? = nil,
        buttonSystemImage: String? = "plus",
        action: (() -> Void)? = nil,
        @ViewBuilder illustration: () -> Illustration
    ) {
        self.illustration = AnyView(illustration())
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.buttonSystemImage = buttonSystemImage
        self.action = action
        self.menuItems = nil
    }
    
    /// SF Symbols のイメージを使う
    init(
        systemImage: String,
        title: String,
        message: String? = nil,
        buttonTitle: String? = nil,
        buttonSystemImage: String? = "plus",
        action: (() -> Void)? = nil
    ) {
        self.init(
            title: title,
            message: message,
            buttonTitle: buttonTitle,
            buttonSystemImage: buttonSystemImage,
            action: action
        ) {
            Image(systemName: systemImage)
                .font(.system(size: 52))
                .foregroundStyle(.secondary)
        }
    }
    
    /// Assets に入れた画像を使う
    init(
        imageName: String,
        imageHeight: CGFloat = 120,
        title: String,
        message: String? = nil,
        buttonTitle: String? = nil,
        buttonSystemImage: String? = "plus",
        action: (() -> Void)? = nil
    ) {
        self.init(
            title: title,
            message: message,
            buttonTitle: buttonTitle,
            buttonSystemImage: buttonSystemImage,
            action: action
        ) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: imageHeight)
        }
    }
    
    /// SF Symbols のイメージ ＋ ボタンを押すとメニューが開く（選択肢から選ばせたい時）
    /// ※ 通常の action 版と区別するため、ラベルは buttonMenu にしている
    init<MenuItems: View>(
        systemImage: String,
        title: String,
        message: String? = nil,
        buttonTitle: String,
        buttonSystemImage: String? = "plus",
        @ViewBuilder buttonMenu: () -> MenuItems
    ) {
        self.illustration = AnyView(
            Image(systemName: systemImage)
                .font(.system(size: 52))
                .foregroundStyle(.secondary)
        )
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.buttonSystemImage = buttonSystemImage
        self.action = nil
        self.menuItems = AnyView(buttonMenu())
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            illustration
            
            VStack(spacing: 6) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
                
                if let message {
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .multilineTextAlignment(.center)
            
            actionButton
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    /// 追加ボタン。メニューがあればメニュー、なければ、文字と動作が両方ある時だけ普通のボタン
    @ViewBuilder
    private var actionButton: some View {
        if let buttonTitle, let menuItems {
            Menu {
                menuItems
            } label: {
                buttonLabel(buttonTitle)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
            .padding(.top, 4)
        } else if let buttonTitle, let action {
            Button(action: action) {
                buttonLabel(buttonTitle)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
            .padding(.top, 4)
        }
    }
    
    @ViewBuilder
    private func buttonLabel(_ title: String) -> some View {
        if let buttonSystemImage {
            Label(title, systemImage: buttonSystemImage)
        } else {
            Text(title)
        }
    }
}

// MARK: - Preview

#Preview("SF Symbols") {
    EmptyStateView(
        systemImage: "folder.badge.plus",
        title: "フォルダがありません",
        message: "フォルダを追加して、買うものを整理しましょう。",
        buttonTitle: "フォルダを追加"
    ) {
        print("追加")
    }
    .tint(Color(red: 0.18, green: 0.55, blue: 0.37))
}

#Preview("メニュー付きボタン") {
    EmptyStateView(
        systemImage: "folder.badge.plus",
        title: "まだ何もありません",
        message: "フォルダやアイテムを追加しましょう。",
        buttonTitle: "追加",
        buttonMenu: {
            Button("フォルダを追加", systemImage: "folder.badge.plus") { print("フォルダ") }
            Button("アイテムを追加", systemImage: "plus") { print("アイテム") }
        }
    )
    .tint(Color(red: 0.18, green: 0.55, blue: 0.37))
}

#Preview("自由なイメージ") {
    EmptyStateView(
        title: "買うものがありません",
        message: "右上の＋から、アイテムを追加できます。",
        buttonTitle: "アイテムを追加",
        action: { print("追加") }
    ) {
        Circle()
            .fill(Color.accentColor.opacity(0.15))
            .frame(width: 96, height: 96)
            .overlay {
                Image(systemName: "cart")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.accentColor)
            }
    }
    .tint(Color(red: 0.18, green: 0.55, blue: 0.37))
}

#Preview("ボタンなし") {
    EmptyStateView(
        systemImage: "clock.arrow.circlepath",
        title: "購入履歴がありません",
        message: "買ったものを完了にして削除すると、ここに記録されます。"
    )
}

#Preview("リストの上に重ねる") {
    NavigationStack {
        List { }
            .overlay {
                EmptyStateView(
                    systemImage: "star",
                    title: "まだ登録がありません",
                    message: "よく買うものを登録すると、ここから選んで、まとめてリストに追加できます。",
                    buttonTitle: "よく買うものを登録"
                ) {
                    print("登録")
                }
            }
            .navigationTitle("よく買うもの")
    }
    .tint(Color(red: 0.18, green: 0.55, blue: 0.37))
}
