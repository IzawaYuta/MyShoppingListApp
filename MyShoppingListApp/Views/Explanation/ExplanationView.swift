
import SwiftUI

// MARK: - Model

struct RecurringIntroPage: Identifiable {
    let id: Int
    let imageName: String
    let title: String
    let description: String
    var highlight: String? = nil
    var descriptionAlignment: TextAlignment = .center
}

// MARK: - Main View

struct RecurringItemIntroView: View {
    
    @State private var currentPage = 0
    
    var onFinish: () -> Void = {}
    
    private let accentColor = Color(
        red: 0.25,
        green: 0.66,
        blue: 0.49
    )
    
    private var isLastPage: Bool {
        currentPage == pages.count - 1
    }
    
    private let pages: [RecurringIntroPage] = [
        RecurringIntroPage(
            id: 0,
            imageName: "RecurringIntro1",
            title: "定期アイテムで\n買い忘れを防ぎましょう",
            description: "設定した日付に、\n指定したフォルダへ\n自動で追加されます。",
            highlight: "自動"
        ),
        RecurringIntroPage(
            id: 1,
            imageName: "RecurringIntro2",
            title: "設定は3ステップだけ",
            description: "① アイテムを登録\n② 頻度を選ぶ\n③ 追加するフォルダを選ぶ",
            descriptionAlignment: .leading
        ),
    ]
    
    var body: some View {
        GeometryReader { geometry in
            
            VStack(spacing: 0) {
                
                // MARK: Page
                
                TabView(selection: $currentPage) {
                    ForEach(pages) { page in
                        pageContent(
                            page,
                            height: geometry.size.height
                        )
                        .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // MARK: Page Indicator
                
                HStack(spacing: 8) {
                    ForEach(0..<2, id: \.self) { index in
                        Circle()
                            .fill(
                                currentPage == index
                                ? accentColor
                                : Color.gray.opacity(0.22)
                            )
                            .frame(width: 7, height: 7)
                    }
                }
                .padding(.bottom, 15)
                
                // MARK: Button
                
                Button {
                    if !isLastPage {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            currentPage += 1
                        }
                    } else {
                        onFinish()
                    }
                } label: {
                    Text(isLastPage ? "完了" : "次へ")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(accentColor)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 18)
                
                // MARK: Skip
                
                Button("スキップ") {
                    onFinish()
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(accentColor)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
        .background(Color(red: 0.96, green: 0.96, blue: 0.98))
    }
    
    // MARK: - Page Content
    
    private func pageContent(
        _ page: RecurringIntroPage,
        height: CGFloat
    ) -> some View {
        
        VStack(spacing: 0) {
            
            // Title
            
            Text(page.title)
                .font(.system(size: 25, weight: .bold))
                .foregroundStyle(Color.primary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 12)
                .padding(.top, 12)
            
            // Description
            
            descriptionText(page)
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(page.descriptionAlignment)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 12)
            
            Spacer(minLength: 12)
            
            // Illustration
            
            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: height * 0.43)
            
            Spacer(minLength: 8)
        }
        .padding(.horizontal, 12)
        .padding(.top, 50)
    }
    
    /// 文字の強調
    private func descriptionText(_ page: RecurringIntroPage) -> Text {
        var attributed = AttributedString(page.description)
        
        if let highlight = page.highlight,
           let range = attributed.range(of: highlight) {
            attributed[range].font = .system(size: 18, weight: .bold)
            attributed[range].foregroundColor = .red.opacity(0.7)
        }
        
        return Text(attributed)
    }
}

// MARK: - Preview

#Preview {
    RecurringItemIntroView()
}
