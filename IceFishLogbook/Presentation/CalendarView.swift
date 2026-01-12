import SwiftUI

struct CalendarView: View {
    @Binding var sessions: [FishingSession]
    @State private var currentMonth = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Month", selection: $currentMonth, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .onChange(of: currentMonth) { _ in }
                
                List {
                    ForEach(sessions.filter { Calendar.current.isDate($0.date, equalTo: currentMonth, toGranularity: .month) }) { session in
                        NavigationLink(destination: SessionDetailsView(session: session, sessions: $sessions)) {
                            HStack {
                                Text(shortDateFormatter.string(from: session.date))
                                    .font(.headline)
                                Spacer()
                                Text(session.overallResult)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(resultColor(for: session.overallResult).opacity(0.2))
                                    .foregroundColor(resultColor(for: session.overallResult))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.blue.opacity(0.05).ignoresSafeArea())
        }
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
