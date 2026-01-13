import SwiftUI
import Firebase
import FirebaseAuth

@main
struct IceFishLogbookApp: App {
    
    @StateObject private var appState = AppState()
    @StateObject private var sessionViewModel = SessionViewModel()
    
    init() {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Configure appearance
        setupAppearance()
        
        Auth.auth().signInAnonymously()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(sessionViewModel)
                // .preferredColorScheme(.dark)
        }
    }
    
    private func setupAppearance() {
        // Navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.iceBackground)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color.deepIce),
            .font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color.iceBackground)
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
}

class AppState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    @Published var isLoading = false
    @Published var showingSplash = true
    
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
}
