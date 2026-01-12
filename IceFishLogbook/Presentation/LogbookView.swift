import SwiftUI

struct LogbookView: View {
    @Binding var sessions: [FishingSession]
    @State private var showAddSession = false
    
    var recentSessions: [FishingSession] {
        sessions.sorted(by: { $0.date > $1.date }).prefix(10).map { $0 } // Last 10
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(recentSessions) { session in
                    NavigationLink(destination: SessionDetailsView(session: session, sessions: $sessions)) {
                        SessionCardView(session: session)
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
    }
}
