import SwiftUI

struct StatsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: SessionViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient.iceBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        if let stats = viewModel.stats {
                            // Total sessions card
                            totalSessionsCard(stats: stats)
                            
                            // Results breakdown
                            resultsBreakdownCard(stats: stats)
                            
                            // Fish statistics
                            fishStatisticsCard
                            
                            // Best conditions
                            bestConditionsCard(stats: stats)
                        } else {
                            emptyStatsView
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.frostBlue)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func totalSessionsCard(stats: FishingStats) -> some View {
        VStack(spacing: 16) {
            // Large number
            Text("\(stats.totalSessions)")
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(.deepIce)
            
            Text("Total Ice Sessions")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.winterGray)
            
            // Icon decoration
            Image(systemName: "snowflake")
                .font(.system(size: 40))
                .foregroundColor(.frostBlue.opacity(0.3))
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.snowWhite)
                .shadow(color: Color.deepIce.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    private func resultsBreakdownCard(stats: FishingStats) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Session Results")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.deepIce)
            
            VStack(spacing: 16) {
                ResultBar(
                    label: "Good",
                    count: stats.goodSessions,
                    total: stats.totalSessions,
                    color: .resultGood
                )
                
                ResultBar(
                    label: "Normal",
                    count: stats.normalSessions,
                    total: stats.totalSessions,
                    color: .resultNormal
                )
                
                ResultBar(
                    label: "Poor",
                    count: stats.poorSessions,
                    total: stats.totalSessions,
                    color: .resultPoor
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.snowWhite)
                .shadow(color: Color.deepIce.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
    
    private var fishStatisticsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Fish Caught")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.deepIce)
            
            let fishFrequency = viewModel.getFishFrequency()
            
            if fishFrequency.isEmpty {
                Text("No fish logged yet")
                    .font(.system(size: 15))
                    .foregroundColor(.winterGray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(fishFrequency, id: \.0) { fish, count in
                        FishStatRow(fish: fish, count: count)
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.snowWhite)
                .shadow(color: Color.deepIce.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
    
    private func bestConditionsCard(stats: FishingStats) -> some View {
        VStack(spacing: 16) {
            // Most common fish
            if let mostCommonFish = stats.mostCommonFish {
                StatInfoCard(
                    icon: "fish.fill",
                    title: "Most Common Fish",
                    value: mostCommonFish.rawValue,
                    color: .glacierGreen
                )
            }
            
            // Best ice condition
            if let bestIce = stats.bestIceCondition {
                StatInfoCard(
                    icon: bestIce.icon,
                    title: "Best Ice Conditions",
                    value: bestIce.rawValue,
                    color: Color(bestIce.color)
                )
            }
            
            // Best day
            if let bestDay = stats.bestDay {
                StatInfoCard(
                    icon: "calendar.badge.checkmark",
                    title: "Recent Good Day",
                    value: formattedDate(bestDay),
                    color: .frostBlue
                )
            }
        }
    }
    
    private var emptyStatsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar")
                .font(.system(size: 60))
                .foregroundColor(.winterGray.opacity(0.5))
            
            Text("No Statistics Yet")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.winterGray)
            
            Text("Start logging your ice fishing sessions to see statistics and insights")
                .font(.system(size: 15))
                .foregroundColor(.winterGray.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Result Bar
struct ResultBar: View {
    let label: String
    let count: Int
    let total: Int
    let color: Color
    
    private var percentage: Double {
        total > 0 ? Double(count) / Double(total) : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.deepIce)
                
                Spacer()
                
                Text("\(count)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(color)
                
                Text("(\(Int(percentage * 100))%)")
                    .font(.system(size: 13))
                    .foregroundColor(.winterGray)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.2))
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(percentage))
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Fish Stat Row
struct FishStatRow: View {
    let fish: FishSpecies
    let count: Int
    
    var body: some View {
        HStack(spacing: 12) {
            Text(fish.emoji)
                .font(.system(size: 24))
            
            Text(fish.rawValue)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.deepIce)
            
            Spacer()
            
            Text("\(count)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.glacierGreen)
            
            Text(count == 1 ? "session" : "sessions")
                .font(.system(size: 13))
                .foregroundColor(.winterGray)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.glacierGreen.opacity(0.08))
        )
    }
}

// MARK: - Stat Info Card
struct StatInfoCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(color.opacity(0.15))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.winterGray)
                
                Text(value)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.deepIce)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.snowWhite)
                .shadow(color: Color.deepIce.opacity(0.08), radius: 6, x: 0, y: 2)
        )
    }
}

// MARK: - Preview
struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
            .environmentObject(SessionViewModel())
    }
}
