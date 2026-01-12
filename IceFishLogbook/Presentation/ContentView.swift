import SwiftUI

struct ContentView: View {
    @State private var sessions: [FishingSession] = loadSessions()
    @State private var showAddSession = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sessions.sorted(by: { $0.date > $1.date })) { session in
                    NavigationLink(destination: SessionDetailsView(session: session, sessions: $sessions)) {
                        HStack(spacing: 16) {
                            Image(systemName: "snowflake")
                                .foregroundColor(.blue)
                                .font(.system(size: 24))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(dateFormatter.string(from: session.date))
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(session.location)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text(session.overallResult)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(resultColor(for: session.overallResult).opacity(0.2))
                                    .foregroundColor(resultColor(for: session.overallResult))
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("My Ice Logbook")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddSession = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 24))
                    }
                }
            }
            .sheet(isPresented: $showAddSession) {
                AddSessionView { newSession in
                    sessions.append(newSession)
                    saveSessions(sessions)
                }
            }
            .background(Color.blue.opacity(0.05).ignoresSafeArea())
        }
        .accentColor(.blue)
    }
    
    private func resultColor(for result: String) -> Color {
        switch result {
        case "Good": return .green
        case "Normal": return .gray
        case "Poor": return .red
        default: return .gray
        }
    }
}

#Preview {
    ContentView()
}
