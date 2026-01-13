import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: SessionViewModel
    @State private var showingResetAlert = false
    @State private var showingExportSheet = false
    @State private var showingAbout = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient.iceBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // App info section
                        appInfoSection
                        
                        // Data section
                        dataSection
                        
                        // About section
                        aboutSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert(isPresented: $showingResetAlert) {
                Alert(
                    title: Text("Reset All Data"),
                    message: Text("This will permanently delete all your fishing sessions. This action cannot be undone. Are you sure?"),
                    primaryButton: .destructive(Text("Reset")) {
                        resetData()
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $showingExportSheet) {
                ExportView()
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
        }
    }
    
    private var appInfoSection: some View {
        VStack(spacing: 20) {
            // App icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient.deepIceGradient
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "snowflake")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(.snowWhite)
            }
            
            VStack(spacing: 4) {
                Text("Ice Fish Logbook")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.deepIce)
                
                Text("Version 1.0.0")
                    .font(.system(size: 14))
                    .foregroundColor(.winterGray)
            }
            
            // Session count
            HStack(spacing: 24) {
                StatPill(value: "\(viewModel.sessions.count)", label: "Sessions")
                
                if let stats = viewModel.stats {
                    StatPill(value: "\(stats.goodSessions)", label: "Good")
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.snowWhite)
                .shadow(color: Color.deepIce.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Data Management")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.deepIce)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                SettingsButton(
                    icon: "square.and.arrow.up",
                    title: "Export Data",
                    subtitle: "Export your logbook as CSV",
                    color: .frostBlue
                ) {
                    showingExportSheet = true
                }
                
                Divider()
                    .padding(.leading, 56)
                
                SettingsButton(
                    icon: "trash.circle",
                    title: "Reset All Data",
                    subtitle: "Permanently delete all sessions",
                    color: .red
                ) {
                    showingResetAlert = true
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.snowWhite)
            )
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.deepIce)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                SettingsButton(
                    icon: "info.circle",
                    title: "About Ice Fish Logbook",
                    subtitle: "Learn more about the app",
                    color: .frostBlue
                ) {
                    showingAbout = true
                }
                
                Divider()
                    .padding(.leading, 56)
                
//                SettingsButton(
//                    icon: "doc.text",
//                    title: "Privacy Policy",
//                    subtitle: "How we handle your data",
//                    color: .frostBlue
//                ) {
//                    // Privacy policy action
//                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.snowWhite)
            )
        }
    }
    
    private func resetData() {
        viewModel.resetAllData { success in
            if success {
                print("Data reset successful")
            } else {
                print("Data reset failed")
            }
        }
    }
}

// MARK: - Stat Pill
struct StatPill: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.frostBlue)
            
            Text(label)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.winterGray)
        }
        .frame(width: 80)
    }
}

// MARK: - Settings Button
struct SettingsButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.deepIce)
                    
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.winterGray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.winterGray.opacity(0.5))
            }
            .padding(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Export View
struct ExportView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: SessionViewModel
    @State private var showingShareSheet = false
    @State private var csvData: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient.iceBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Info card
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.frostBlue)
                        
                        Text("Export Your Logbook")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.deepIce)
                        
                        Text("Your fishing data will be exported as a CSV file that you can open in Excel, Numbers, or any spreadsheet application.")
                            .font(.system(size: 15))
                            .foregroundColor(.winterGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(32)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.snowWhite)
                    )
                    
                    // Export info
                    VStack(spacing: 12) {
                        InfoRow(label: "Total Sessions", value: "\(viewModel.sessions.count)")
                        InfoRow(label: "Format", value: "CSV")
                        InfoRow(label: "Includes", value: "All session data & notes")
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.snowWhite)
                    )
                    
                    Spacer()
                    
                    // Export button
                    Button(action: exportData) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Export Data")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.snowWhite)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient.deepIceGradient
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.deepIce.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
                .padding()
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.frostBlue)
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [csvData])
        }
    }
    
    private func exportData() {
        csvData = viewModel.exportToCSV()
        showingShareSheet = true
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.winterGray)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.deepIce)
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - About View
struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient.iceBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Logo
                        ZStack {
                            Circle()
                                .fill(LinearGradient.deepIceGradient)
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "snowflake")
                                .font(.system(size: 50, weight: .light))
                                .foregroundColor(.snowWhite)
                        }
                        .padding(.top, 20)
                        
                        // App info
                        VStack(spacing: 8) {
                            Text("Ice Fish Logbook")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.deepIce)
                            
                            Text("Version 1.0.0")
                                .font(.system(size: 16))
                                .foregroundColor(.winterGray)
                        }
                        
                        // Description
                        Text("A personal journal for ice fishers to log trips, track conditions, and review their winter fishing history.")
                            .font(.system(size: 15))
                            .foregroundColor(.winterGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        // Features
                        VStack(alignment: .leading, spacing: 16) {
                            FeatureRow(icon: "book.fill", text: "Log ice fishing sessions")
                            FeatureRow(icon: "cloud.snow.fill", text: "Track weather & ice conditions")
                            FeatureRow(icon: "fish.fill", text: "Record fish caught")
                            FeatureRow(icon: "calendar", text: "Calendar view of sessions")
                            FeatureRow(icon: "chart.bar.fill", text: "Statistics & insights")
                            FeatureRow(icon: "square.and.arrow.up", text: "Export your data")
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.snowWhite)
                        )
                        
                        // Credits
                        Text("Made with ❄️ for ice fishing enthusiasts")
                            .font(.system(size: 14))
                            .foregroundColor(.winterGray.opacity(0.8))
                            .padding(.top, 20)
                    }
                    .padding()
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.frostBlue)
                }
            }
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.frostBlue)
                .frame(width: 32)
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.deepIce)
            
            Spacer()
        }
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(SessionViewModel())
    }
}
