import SwiftUI

struct LogbookView: View {
    
    @EnvironmentObject var viewModel: SessionViewModel
    @State private var showingAddSession = false
    @State private var showingStats = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient.iceBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header card
                        headerCard
                        
                        // Quick stats
                        if let stats = viewModel.stats {
                            quickStatsCard(stats: stats)
                        }
                        
                        // Recent sessions
                        recentSessionsSection
                    }
                    .padding()
                }
                
                // Floating add button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingAddSession = true }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.snowWhite)
                                .frame(width: 64, height: 64)
                                .background(
                                    LinearGradient.deepIceGradient
                                )
                                .clipShape(Circle())
                                .shadow(color: Color.deepIce.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("My Ice Logbook")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAddSession) {
                AddSessionView()
            }
            .sheet(isPresented: $showingStats) {
                StatsView()
            }
        }
    }
    
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Winter Fishing Records")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.winterGray)
                    
                    Text("\(viewModel.sessions.count) Total Sessions")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.deepIce)
                }
                
                Spacer()
                
                // Ice icon
                Image(systemName: "snowflake")
                    .font(.system(size: 40))
                    .foregroundColor(.frostBlue.opacity(0.6))
            }
            
            // Season info
            if let firstSession = viewModel.sessions.last,
               let lastSession = viewModel.sessions.first {
                HStack {
                    Text("Season: \(formattedDate(firstSession.date)) - \(formattedDate(lastSession.date))")
                        .font(.system(size: 14))
                        .foregroundColor(.winterGray)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.snowWhite)
                .shadow(color: Color.deepIce.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
    
    private func quickStatsCard(stats: FishingStats) -> some View {
        HStack(spacing: 16) {
            StatBubble(
                value: "\(stats.goodSessions)",
                label: "Good",
                color: .resultGood
            )
            
            StatBubble(
                value: "\(stats.normalSessions)",
                label: "Normal",
                color: .resultNormal
            )
            
            StatBubble(
                value: "\(stats.poorSessions)",
                label: "Poor",
                color: .resultPoor
            )
            
            Spacer()
            
            Button(action: { showingStats = true }) {
                HStack {
                    Text("View Stats")
                        .font(.system(size: 14, weight: .semibold))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.frostBlue)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.snowWhite)
                .shadow(color: Color.deepIce.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
    
    private var recentSessionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Sessions")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.deepIce)
                
                Spacer()
                
                if viewModel.sessions.count > 5 {
                    NavigationLink(destination: SessionsListView()) {
                        Text("See All")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.frostBlue)
                    }
                }
            }
            
            if viewModel.sessions.isEmpty {
                EmptySessionsView()
            } else {
                ForEach(Array(viewModel.sessions.prefix(5))) { session in
                    NavigationLink(destination: SessionDetailView(session: session)) {
                        SessionCardView(session: session)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Stat Bubble
struct StatBubble: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.winterGray)
        }
        .frame(width: 70)
    }
}

struct SessionCardView: View {
    let session: FishingSession
    
    var body: some View {
        HStack(spacing: 16) {
            // Date circle
            VStack(spacing: 4) {
                Text(dayString(from: session.date))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.deepIce)
                
                Text(monthString(from: session.date))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.winterGray)
            }
            .frame(width: 60, height: 60)
            .background(
                Circle()
                    .fill(Color(session.overallResult.color).opacity(0.2))
            )
            
            // Session info
            VStack(alignment: .leading, spacing: 6) {
                Text(session.location.isEmpty ? "Unknown Location" : session.location)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.deepIce)
                    .lineLimit(1)
                
                HStack(spacing: 12) {
                    Label(session.waterType.rawValue, systemImage: session.waterType.icon)
                        .font(.system(size: 13))
                        .foregroundColor(.winterGray)
                    
                    if !session.fishCaught.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "fish.fill")
                            Text("\(session.fishCaught.count)")
                        }
                        .font(.system(size: 13))
                        .foregroundColor(.glacierGreen)
                    }
                }
            }
            
            Spacer()
            
            // Result indicator
            Image(systemName: session.overallResult.icon)
                .font(.system(size: 20))
                .foregroundColor(Color(session.overallResult.color))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.snowWhite)
                .shadow(color: Color.deepIce.opacity(0.08), radius: 6, x: 0, y: 2)
        )
    }
    
    private func dayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: date)
    }
    
    private func monthString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date).uppercased()
    }
}

// MARK: - Empty Sessions View
struct EmptySessionsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.winterGray.opacity(0.5))
            
            Text("No fishing sessions yet")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.winterGray)
            
            Text("Tap the + button to log your first ice fishing trip")
                .font(.system(size: 14))
                .foregroundColor(.winterGray.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.snowWhite)
                .shadow(color: Color.deepIce.opacity(0.08), radius: 6, x: 0, y: 2)
        )
    }
}

// MARK: - Preview
struct LogbookView_Previews: PreviewProvider {
    static var previews: some View {
        LogbookView()
            .environmentObject(SessionViewModel())
    }
}
