import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab(String(localized: "tab.week"), systemImage: "sparkles") {
                NavigationStack {
                    WeeklyView()
                        .navigationTitle(String(localized: "weekly.title"))
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            Tab(String(localized: "tab.signs"), systemImage: "circle.grid.2x2") {
                SignsGridView()
            }
            Tab(String(localized: "tab.profile"), systemImage: "person.crop.circle") {
                NavigationStack {
                    ProfileView()
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
        .tint(.white)
    }
}
