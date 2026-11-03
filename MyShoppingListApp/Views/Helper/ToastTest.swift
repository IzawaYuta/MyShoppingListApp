import SwiftUI

/// トーストの動きを試すためのテスト画面（本番のアプリには含めなくてよい）
struct ToastTestView: View {
    @Environment(ToastCenter.self) private var toast
    
    @State private var message = "3件をリストに追加しました"
    @State private var kind: ToastKindOption = .success
    @State private var animation: ToastAnimation = .banner
    @State private var duration = 2.5
    
    var body: some View {
        Form {
            Section("メッセージ") {
                TextField("メッセージ", text: $message)
                Picker("種類", selection: $kind) {
                    ForEach(ToastKindOption.allCases) { Text($0.title).tag($0) }
                }
            }
            
            Section("アニメーション") {
                Picker("出方", selection: $animation) {
                    ForEach(ToastAnimation.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            
            Section("表示時間") {
                Slider(value: $duration, in: 1...6, step: 0.5)
                Text("\(duration, specifier: "%.1f")秒")
                    .foregroundStyle(.secondary)
            }
            
            Section {
                Button("この設定で表示") {
                    toast.show(message, kind: kind.kind, animation: animation, duration: duration)
                }
                Button("連続で3回表示（入れ替わりの確認）") {
                    Task {
                        for number in 1...3 {
                            toast.show("\(number)つ目のメッセージ", kind: kind.kind, animation: animation)
                            try? await Task.sleep(for: .seconds(0.8))
                        }
                    }
                }
                Button("すべての出方を順番に表示") {
                    Task {
                        for style in ToastAnimation.allCases {
                            toast.show(style.title, kind: kind.kind, animation: style, duration: 1.4)
                            try? await Task.sleep(for: .seconds(2.0))
                        }
                    }
                }
                Button("閉じる", role: .destructive) { toast.dismiss() }
            }
        }
        .navigationTitle("トーストのテスト")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// テスト画面で種類を選ぶための補助（ToastKind は Picker で使えないため）
private enum ToastKindOption: String, CaseIterable, Identifiable {
    case success, info, warning, error
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .success: return "成功"
        case .info:    return "お知らせ"
        case .warning: return "注意"
        case .error:   return "エラー"
        }
    }
    
    var kind: ToastKind {
        switch self {
        case .success: return .success
        case .info:    return .info
        case .warning: return .warning
        case .error:   return .error
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ToastTestView()
    }
    .toastHost(ToastCenter())
    .tint(Color(red: 0.18, green: 0.55, blue: 0.37))
}
