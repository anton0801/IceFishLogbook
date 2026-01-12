import SwiftUI

struct SessionCardView: View {
    let session: FishingSession
    
    var body: some View {
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
    
    private func resultColor(for result: String) -> Color {
        switch result {
        case "Good": return .green
        case "Normal": return .gray
        case "Poor": return .red
        default: return .gray
        }
    }
}
