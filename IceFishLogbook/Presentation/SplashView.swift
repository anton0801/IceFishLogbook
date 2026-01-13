import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var snowflakes: [Snowflake] = []
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient.iceBackground
                .ignoresSafeArea()
            
            // Animated snowflakes
            ForEach(snowflakes) { snowflake in
                SnowflakeView(snowflake: snowflake)
            }
            
            // Logo and title
            VStack(spacing: 20) {
                // Ice fishing logo
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.frostBlue.opacity(0.3), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                    
                    // Logo circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.deepIce, Color.frostBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .overlay(
                            Circle()
                                .stroke(Color.snowWhite.opacity(0.3), lineWidth: 2)
                        )
                    
                    // Fish icon
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.snowWhite)
                        .rotationEffect(.degrees(-45))
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                
                // App title
                VStack(spacing: 8) {
                    Text("Ice Fish Logbook")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.deepIce)
                    
                    Text("Winter Fishing Records")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.winterGray)
                }
                .opacity(titleOpacity)
            }
        }
        .onAppear {
            startAnimations()
            generateSnowflakes()
        }
    }
    
    private func startAnimations() {
        // Logo animation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Title animation with delay
        withAnimation(.easeIn(duration: 0.6).delay(0.3)) {
            titleOpacity = 1.0
        }
    }
    
    private func generateSnowflakes() {
        for _ in 0..<20 {
            let snowflake = Snowflake(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: -100...UIScreen.main.bounds.height),
                size: CGFloat.random(in: 4...12),
                speed: Double.random(in: 2...5),
                opacity: Double.random(in: 0.3...0.8)
            )
            snowflakes.append(snowflake)
        }
    }
}

// MARK: - Snowflake Model
struct Snowflake: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let speed: Double
    let opacity: Double
}

// MARK: - Snowflake View
struct SnowflakeView: View {
    let snowflake: Snowflake
    @State private var yPosition: CGFloat
    @State private var xOffset: CGFloat = 0
    
    init(snowflake: Snowflake) {
        self.snowflake = snowflake
        _yPosition = State(initialValue: snowflake.y)
    }
    
    var body: some View {
        Image(systemName: "snow")
            .font(.system(size: snowflake.size))
            .foregroundColor(.snowWhite)
            .opacity(snowflake.opacity)
            .position(x: snowflake.x + xOffset, y: yPosition)
            .onAppear {
                animateSnowflake()
            }
    }
    
    private func animateSnowflake() {
        // Falling animation
        withAnimation(
            .linear(duration: snowflake.speed)
            .repeatForever(autoreverses: false)
        ) {
            yPosition = UIScreen.main.bounds.height + 100
        }
        
        // Horizontal drift
        withAnimation(
            .easeInOut(duration: snowflake.speed / 2)
            .repeatForever(autoreverses: true)
        ) {
            xOffset = CGFloat.random(in: -30...30)
        }
    }
}

// MARK: - Preview
struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
