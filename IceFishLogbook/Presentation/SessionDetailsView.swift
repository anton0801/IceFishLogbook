import SwiftUI

struct SessionDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: SessionViewModel
    
    let session: FishingSession
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ZStack {
            LinearGradient.iceBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header card with result
                    headerCard
                    
                    // Location and date
                    infoCard
                    
                    // Conditions
                    conditionsCard
                    
                    // Fish caught
                    if !session.fishCaught.isEmpty {
                        fishCard
                    }
                    
                    // Notes
                    if !session.notes.isEmpty {
                        notesCard
                    }
                    
                    // Action buttons
                    actionButtons
                }
                .padding()
            }
        }
        .navigationTitle("Session Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            EditSessionView(session: session)
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Session"),
                message: Text("Are you sure you want to delete this fishing session? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    deleteSession()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private var headerCard: some View {
        VStack(spacing: 16) {
            // Result icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(session.overallResult.color).opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Circle()
                    .fill(Color(session.overallResult.color))
                    .frame(width: 70, height: 70)
                
                Image(systemName: session.overallResult.icon)
                    .font(.system(size: 32))
                    .foregroundColor(.snowWhite)
            }
            
            // Result text
            Text(session.overallResult.rawValue)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.deepIce)
            
            Text("Fishing Session")
                .font(.system(size: 14))
                .foregroundColor(.winterGray)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.snowWhite)
                .shadow(color: Color.deepIce.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    private var infoCard: some View {
        VStack(spacing: 16) {
            DetailRow(
                icon: "calendar",
                title: "Date",
                value: formattedDate(session.date)
            )
            
            Divider()
            
            DetailRow(
                icon: "mappin.circle.fill",
                title: "Location",
                value: session.location
            )
            
            Divider()
            
            DetailRow(
                icon: session.waterType.icon,
                title: "Water Type",
                value: session.waterType.rawValue
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.snowWhite)
                .shadow(color: Color.deepIce.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
    
    private var conditionsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Conditions")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.deepIce)
            
            // Ice condition
            HStack(spacing: 12) {
                Image(systemName: session.iceCondition.icon)
                    .font(.system(size: 24))
                    .foregroundColor(Color(session.iceCondition.color))
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ice Condition")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.winterGray)
                    Text(session.iceCondition.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.deepIce)
                }
                
                Spacer()
            }
            
            if !session.weather.isEmpty {
                Divider()
                
                // Weather conditions
                HStack(spacing: 12) {
                    Image(systemName: "cloud.sun.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.frostBlue)
                        .frame(width: 40)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Weather")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.winterGray)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(session.weather, id: \.self) { weather in
                                HStack(spacing: 4) {
                                    Image(systemName: weather.icon)
                                    Text(weather.rawValue)
                                }
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.frostBlue)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.frostBlue.opacity(0.1))
                                )
                            }
                        }
                    }
                    
                    Spacer()
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
    
    private var fishCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "fish.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.glacierGreen)
                
                Text("Fish Caught")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.deepIce)
            }
            
            FlowLayout(spacing: 12) {
                ForEach(session.fishCaught, id: \.self) { fish in
                    HStack(spacing: 8) {
                        Text(fish.emoji)
                            .font(.system(size: 20))
                        Text(fish.rawValue)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.deepIce)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.glacierGreen.opacity(0.15))
                    )
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
    
    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "note.text")
                    .font(.system(size: 18))
                    .foregroundColor(.frostBlue)
                
                Text("Notes")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.deepIce)
            }
            
            Text(session.notes)
                .font(.system(size: 15))
                .foregroundColor(.winterGray)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.snowWhite)
                .shadow(color: Color.deepIce.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button(action: { showingEditSheet = true }) {
                HStack {
                    Image(systemName: "pencil")
                    Text("Edit")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.frostBlue)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.frostBlue.opacity(0.1))
                )
            }
            
            Button(action: { showingDeleteAlert = true }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red.opacity(0.1))
                )
            }
        }
    }
    
    private func deleteSession() {
        viewModel.deleteSession(session)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.frostBlue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.winterGray)
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.deepIce)
            }
            
            Spacer()
        }
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

// MARK: - Preview
struct SessionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SessionDetailView(session: FishingSession(
                location: "Crystal Lake",
                waterType: .lake,
                iceCondition: .thick,
                weather: [.cold, .clear],
                fishCaught: [.perch, .pike],
                overallResult: .good,
                notes: "Great day on the ice. Found a good spot near the reeds. Ice was solid at 12 inches."
            ))
            .environmentObject(SessionViewModel())
        }
    }
}
