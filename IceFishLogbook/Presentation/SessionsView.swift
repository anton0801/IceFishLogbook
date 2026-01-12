import SwiftUI

struct SessionsView: View {
    @Binding var sessions: [FishingSession]
    @State private var sortByDate = true // Toggle for sorting
    
    var sortedSessions: [FishingSession] {
        if sortByDate {
            return sessions.sorted(by: { $0.date > $1.date })
        } else {
            return sessions.sorted(by: { $0.overallResult > $1.overallResult }) // Simple sort by result
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sortedSessions) { session in
                    NavigationLink(destination: SessionDetailsView(session: session, sessions: $sessions)) {
                        SessionCardView(session: session)
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("All Sessions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        sortByDate.toggle()
                    }) {
                        Image(systemName: sortByDate ? "calendar" : "arrow.up.arrow.down")
                            .foregroundColor(.blue)
                    }
                }
            }
            .background(Color.blue.opacity(0.05).ignoresSafeArea())
        }
    }
}
