import SwiftUI

struct SettingsView: View {
    @Binding var sessions: [FishingSession]
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Units")) {
                    Text("Metric (cm/m)")
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Data")) {
                    Button("Reset Data", role: .destructive) {
                        showResetAlert = true
                    }
                }
                
                Section(header: Text("Info")) {
                    Text("Privacy Policy")
                    Text("About")
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Reset", role: .destructive) {
                    sessions.removeAll()
                    saveSessions(sessions)
                }
                Button("Cancel", role: .cancel) {}
            }
            .background(Color.blue.opacity(0.05).ignoresSafeArea())
        }
    }
}
