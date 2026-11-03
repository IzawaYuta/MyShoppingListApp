
import SwiftUI

// MARK: - 種類（アイコンと色）

/// トーストの種類
enum ToastKind {
    case success, info, warning, error
    
    var systemImage: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .info:    return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error:   return "xmark.octagon.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .success: return .green
        case .info:    return .blue
        case .warning: return .orange
        case .error:   return .red
        }
    }
}

// MARK: - アニメーション

/// トーストの出方。新しい種類を試す時は、case を足して、下の4つの switch に1行ずつ足す
enum ToastAnimation: String, CaseIterable, Identifiable {
    case banner         // 画面の上から降りてくる（バナー通知）
    case bouncyBanner   // 上から降りて、弾む
    case fade           // ふわっと表示
    case pop            // 拡大しながら表示
    case bottom         // 下から上がってくる
    case blur           // ぼかしながら表示
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .banner:       return "バナー（上からスライド）"
        case .bouncyBanner: return "バナー（弾む）"
        case .fade:         return "フェード"
        case .pop:          return "ポップ（拡大）"
        case .bottom:       return "下からスライド"
        case .blur:         return "ぼかしてフェード"
        }
    }
    
    /// 表示している時間（秒）。show で duration を指定しない時に使う
    var defaultDuration: Double {
        switch self {
        case .blur: return 1.8
        default:    return 2.5
        }
    }
    
    /// 表示する位置
    var alignment: Alignment {
        switch self {
        case .banner, .bouncyBanner, .fade, .blur: return .top
        case .pop:                                  return .center
        case .bottom:                               return .bottom
        }
    }
    
    /// 出入りの動き。上下のスライドは、画面の外から動かすため、大きめの距離にしている
    var transition: AnyTransition {
        switch self {
        case .banner, .bouncyBanner:
            return .offset(y: -240).combined(with: .opacity)
        case .fade:
            return .opacity
        case .pop:
            return .scale(scale: 0.6).combined(with: .opacity)
        case .bottom:
            return .offset(y: 240).combined(with: .opacity)
        case .blur:
            return .modifier(active: BlurFade(radius: 16, opacity: 0),
                             identity: BlurFade(radius: 0, opacity: 1))
        }
    }
    
    /// 動きの速さや弾み方
    var animation: Animation {
        switch self {
        case .banner:       return .spring(duration: 0.45, bounce: 0.15)
        case .bouncyBanner: return .spring(response: 0.5, dampingFraction: 0.55)
        case .fade:         return .easeInOut(duration: 0.3)
        case .pop:          return .spring(response: 0.35, dampingFraction: 0.6)
        case .bottom:       return .spring(duration: 0.4, bounce: 0.1)
        case .blur:         return .easeOut(duration: 0.2)
        }
    }
}

/// ぼかし＋透明度の変化（.blur 用）
private struct BlurFade: ViewModifier {
    let radius: CGFloat
    let opacity: Double
    
    func body(content: Content) -> some View {
        content.blur(radius: radius).opacity(opacity)
    }
}

// MARK: - データと管理

/// 表示するトーストの内容
struct ToastItem: Identifiable {
    let id = UUID()
    let message: String
    let systemImage: String
    let color: Color
    let animation: ToastAnimation
}

/// トーストを表示する窓口。アプリの一番上で作って、環境に渡す
/// 使い方：@Environment(ToastCenter.self) private var toast → toast.show("追加しました")
@MainActor
@Observable
final class ToastCenter {
    /// 今表示しているトースト（nil なら非表示）
    private(set) var current: ToastItem?
    /// 閉じる時のアニメーション用に、直前の出方を覚えておく
    private(set) var lastAnimation: ToastAnimation = .blur
    /// animation を指定しない時の出方
    var defaultAnimation: ToastAnimation = .blur
    
    private var dismissTask: Task<Void, Never>?
    
    func show(_ message: String,
              kind: ToastKind = .success,
              systemImage: String? = nil,
              animation: ToastAnimation? = nil,
              duration: Double? = nil) {
        dismissTask?.cancel()
        
        let style = animation ?? defaultAnimation
        let seconds = duration ?? style.defaultDuration
        lastAnimation = style
        current = ToastItem(
            message: message,
            systemImage: systemImage ?? kind.systemImage,
            color: kind.color,
            animation: style
        )
        
        dismissTask = Task {
            try? await Task.sleep(for: .seconds(seconds)) 
            guard !Task.isCancelled else { return }
            current = nil
        }
    }
    
    func dismiss() {
        dismissTask?.cancel()
        current = nil
    }
}

// MARK: - 見た目

/// トースト1つの見た目
struct ToastView: View {
    let item: ToastItem
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: item.systemImage)
                .font(.title3)
                .foregroundStyle(item.color)
            Text(item.message)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: 420, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
        .onTapGesture(perform: onDismiss)                       // タップで閉じる
        .gesture(
            DragGesture(minimumDistance: 10).onEnded { value in // 上下にスワイプで閉じる
                if abs(value.translation.height) > 20 { onDismiss() }
            }
        )
    }
}

// MARK: - 画面に取り付ける

/// 画面全体にトーストを重ねる。NavigationStack や TabView の外側（一番上）に付ける
private struct ToastHost: ViewModifier {
    let center: ToastCenter
    
    func body(content: Content) -> some View {
        // 表示中は今の出方、閉じる時は直前の出方を使う
        let style = center.current?.animation ?? center.lastAnimation
        
        content
            .overlay(alignment: style.alignment) {
                if let item = center.current {
                    ToastView(item: item) { center.dismiss() }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, style.alignment == .bottom ? 64 : 8)   // 下に出す時は、タブバーを避ける
                        .transition(item.animation.transition)
                }
            }
            .animation(style.animation, value: center.current?.id)
    }
}

extension View {
    /// トーストを表示できるようにする。環境にも ToastCenter を渡す
    func toastHost(_ center: ToastCenter) -> some View {
        self
            .environment(center)
            .modifier(ToastHost(center: center))
    }
}


//MARK: - 使い方
//@Environment(ToastCenter.self) private var toast
//// ……
//toast.show("削除しました", kind: .info)
//toast.show("保存に失敗しました", kind: .error, duration: 4)
//toast.show("追加しました", animation: .pop)   // この1回だけ、出方を変える
