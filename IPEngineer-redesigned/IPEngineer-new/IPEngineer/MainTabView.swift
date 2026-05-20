import SwiftUI

struct MainTabView: View {

    init() {
        // 탭바 외관 통일
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.dsSurface)
        appearance.shadowColor = UIColor(Color.dsBorder)

        let item = UITabBarItemAppearance()
        item.normal.iconColor = UIColor(Color.dsTextTertiary)
        item.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.dsTextTertiary),
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        item.selected.iconColor = UIColor(Color.dsBrand)
        item.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.dsBrand),
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]
        appearance.stackedLayoutAppearance = item
        appearance.inlineLayoutAppearance = item
        appearance.compactInlineLayoutAppearance = item

        UITabBar.appearance().standardAppearance = appearance
    }

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("홈")
                }
            SubjectView()
                .tabItem {
                    Image(systemName: "books.vertical.fill")
                    Text("과목")
                }
            AITutorView()
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("AI 튜터")
                }
            WrongNoteView()
                .tabItem {
                    Image(systemName: "doc.text.fill")
                    Text("오답노트")
                }
            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                    Text("통계")
                }
        }
        .accentColor(.dsBrand)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
