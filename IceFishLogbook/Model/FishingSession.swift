import Foundation
import SwiftUI

struct FishingSession: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var location: String
    var waterType: String // "Lake", "River", "Reservoir"
    var iceConditions: String // "Thin", "Normal", "Thick"
    var weather: String // "Cold", "Windy", "Snow", "Clear"
    var fishCaught: [String]
    var overallResult: String // "Poor", "Normal", "Good"
    var notes: String
}

let sessionsKey = "fishingSessions"

func loadSessions() -> [FishingSession] {
    if let data = UserDefaults.standard.data(forKey: sessionsKey) {
        return (try? JSONDecoder().decode([FishingSession].self, from: data)) ?? []
    }
    return []
}

func saveSessions(_ sessions: [FishingSession]) {
    if let data = try? JSONEncoder().encode(sessions) {
        UserDefaults.standard.set(data, forKey: sessionsKey)
    }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

let shortDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d"
    return formatter
}()
