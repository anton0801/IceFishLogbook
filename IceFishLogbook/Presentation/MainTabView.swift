import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            LogbookView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Logbook")
                }
                .tag(0)
            
            SessionsListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Sessions")
                }
                .tag(1)
            
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(3)
        }
        .accentColor(.deepIce)
    }
}
