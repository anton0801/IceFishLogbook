import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0
    @State private var dragOffset: CGFloat = 0
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Log Your Ice Fishing Trips",
            description: "Record every winter fishing adventure with detailed information about location, conditions, and catches.",
            icon: "figure.fishing",
            accentColor: .frostBlue,
            animation: .iceHole
        ),
        OnboardingPage(
            title: "Save Conditions & Notes",
            description: "Track ice thickness, weather patterns, and personal observations to improve your fishing strategy.",
            icon: "snowflake",
            accentColor: .glacierGreen,
            animation: .snowfall
        ),
        OnboardingPage(
            title: "Review Your History",
            description: "Analyze your fishing sessions, view statistics, and discover patterns in your winter fishing success.",
            icon: "chart.bar.fill",
            accentColor: .deepIce,
            animation: .fishSwim
        )
    ]
    
    var body: some View {
        ZStack {
            LinearGradient.iceBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button(action: completeOnboarding) {
                        Text("Skip")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.winterGray)
                    }
                    .padding(.trailing, 24)
                    .padding(.top, 16)
                }
                
                // Paged content with parallax
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(
                            page: pages[index],
                            pageIndex: index,
                            currentPage: $currentPage
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Custom page indicator
                HStack(spacing: 12) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.deepIce : Color.winterGray.opacity(0.3))
                            .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
                            .scaleEffect(index == currentPage ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 20)
                
                // Action button
                Button(action: handleActionButton) {
                    Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.snowWhite)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient.deepIceGradient
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.deepIce.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func handleActionButton() {
        if currentPage < pages.count - 1 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                currentPage += 1
            }
        } else {
            completeOnboarding()
        }
    }
    
    private func completeOnboarding() {
        withAnimation(.easeOut(duration: 0.3)) {
            appState.hasCompletedOnboarding = true
        }
    }
}

// MARK: - Onboarding Page Model
struct OnboardingPage {
    let title: String
    let description: String
    let icon: String
    let accentColor: Color
    let animation: OnboardingAnimation
}

enum OnboardingAnimation {
    case iceHole, snowfall, fishSwim
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage
    let pageIndex: Int
    @Binding var currentPage: Int
    
    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Animated icon container
            ZStack {
                // Background circle with glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [page.accentColor.opacity(0.2), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 140
                        )
                    )
                    .frame(width: 280, height: 280)
                
                // Animated decoration based on page
                animatedDecoration
                
                // Main icon circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [page.accentColor, page.accentColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 160, height: 160)
                    .overlay(
                        Circle()
                            .stroke(Color.snowWhite.opacity(0.3), lineWidth: 3)
                    )
                
                // Icon
                Image(systemName: page.icon)
                    .font(.system(size: 70, weight: .light))
                    .foregroundColor(.snowWhite)
            }
            .scaleEffect(iconScale)
            .opacity(iconOpacity)
            
            // Text content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.deepIce)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(page.description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.winterGray)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 40)
            }
            .opacity(textOpacity)
            
            Spacer()
        }
        .onChange(of: currentPage) { newValue in
            if newValue == pageIndex {
                startAnimations()
            }
        }
        .onAppear {
            if currentPage == pageIndex {
                startAnimations()
            }
        }
    }
    
    @ViewBuilder
    private var animatedDecoration: some View {
        switch page.animation {
        case .iceHole:
            IceHoleAnimation(offset: $animationOffset)
        case .snowfall:
            SnowfallAnimation()
        case .fishSwim:
            FishSwimAnimation(offset: $animationOffset)
        }
    }
    
    private func startAnimations() {
        // Reset states
        iconScale = 0.5
        iconOpacity = 0
        textOpacity = 0
        animationOffset = 0
        
        // Icon animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0).delay(0.1)) {
            iconScale = 1.0
            iconOpacity = 1.0
        }
        
        // Text animation
        withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
            textOpacity = 1.0
        }
        
        // Decoration animation
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.6)) {
            animationOffset = 20
        }
    }
}

// MARK: - Ice Hole Animation
struct IceHoleAnimation: View {
    @Binding var offset: CGFloat
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { index in
                Circle()
                    .stroke(Color.frostBlue.opacity(0.3 - Double(index) * 0.1), lineWidth: 2)
                    .frame(width: 180 + CGFloat(index) * 30, height: 180 + CGFloat(index) * 30)
                    .offset(y: offset * CGFloat(index + 1) * 0.2)
            }
        }
    }
}

// MARK: - Snowfall Animation
struct SnowfallAnimation: View {
    @State private var snowflakes: [SmallSnowflake] = []
    
    var body: some View {
        ZStack {
            ForEach(snowflakes) { flake in
                Image(systemName: "snow")
                    .font(.system(size: flake.size))
                    .foregroundColor(.snowWhite.opacity(flake.opacity))
                    .position(x: flake.x, y: flake.y)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            generateSnowflakes()
        }
    }
    
    private func generateSnowflakes() {
        for _ in 0..<15 {
            let flake = SmallSnowflake(
                x: CGFloat.random(in: 0...280),
                y: CGFloat.random(in: 0...280),
                size: CGFloat.random(in: 6...14),
                opacity: Double.random(in: 0.4...0.9)
            )
            snowflakes.append(flake)
        }
    }
}

struct SmallSnowflake: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let opacity: Double
}

// MARK: - Fish Swim Animation
struct FishSwimAnimation: View {
    @Binding var offset: CGFloat
    
    var body: some View {
        HStack(spacing: 40) {
            Image(systemName: "chevron.right")
                .font(.system(size: 30, weight: .light))
                .foregroundColor(.frostBlue.opacity(0.3))
                .offset(x: -offset)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 30, weight: .light))
                .foregroundColor(.frostBlue.opacity(0.2))
                .offset(x: -offset * 1.5)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 30, weight: .light))
                .foregroundColor(.frostBlue.opacity(0.1))
                .offset(x: -offset * 2)
        }
        .frame(width: 200)
    }
}

// MARK: - Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(AppState())
    }
}
