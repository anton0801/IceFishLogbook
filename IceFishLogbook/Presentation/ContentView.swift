import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            if appState.showingSplash {
                SplashView()
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation(.easeOut(duration: 0.5)) {
                                appState.showingSplash = false
                            }
                        }
                    }
            } else if !appState.hasCompletedOnboarding {
                OnboardingView()
                    .transition(.move(edge: .trailing))
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
            .environmentObject(SessionViewModel())
    }
}
