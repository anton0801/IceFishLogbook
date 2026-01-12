
import SwiftUI

struct SessionDetailsView: View {
    let session: FishingSession
    @Binding var sessions: [FishingSession]
    @State private var showEdit = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text(dateFormatter.string(from: session.date))
                        .font(.title2.bold())
                    Text(session.location)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5)
                
                // Conditions
                VStack(alignment: .leading, spacing: 12) {
                    DetailRow(icon: "drop", title: "Water Type", value: session.waterType)
                    DetailRow(icon: "snowflake", title: "Ice Conditions", value: session.iceConditions)
                    DetailRow(icon: "cloud", title: "Weather", value: session.weather)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5)
                
                // Catch
                VStack(alignment: .leading, spacing: 12) {
                    DetailRow(icon: "fish", title: "Fish Caught", value: session.fishCaught.joined(separator: ", "))
                    DetailRow(icon: "checkmark.circle", title: "Overall Result", value: session.overallResult)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5)
                
                // Notes
                if !session.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text(session.notes)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5)
                }
            }
            .padding()
        }
        .navigationTitle("Session Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Edit") {
                        showEdit = true
                    }
                    Button("Delete", role: .destructive) {
                        showDeleteAlert = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.blue)
                }
            }
        }
        .sheet(isPresented: $showEdit) {
            EditSessionView(session: session) { updatedSession in
                if let index = sessions.firstIndex(where: { $0.id == session.id }) {
                    sessions[index] = updatedSession
                    saveSessions(sessions)
                }
            }
        }
        .alert("Delete Session?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                sessions.removeAll { $0.id == session.id }
                saveSessions(sessions)
            }
            Button("Cancel", role: .cancel) {}
        }
        .background(Color.blue.opacity(0.05).ignoresSafeArea())
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
        }
    }
}
