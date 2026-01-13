import Foundation
import FirebaseDatabase

struct FishingStats {
    var totalSessions: Int
    var mostCommonFish: FishSpecies?
    var bestIceCondition: IceCondition?
    var bestDay: Date?
    var goodSessions: Int
    var normalSessions: Int
    var poorSessions: Int
    
    init(sessions: [FishingSession]) {
        self.totalSessions = sessions.count
        
        // Calculate most common fish
        let allFish = sessions.flatMap { $0.fishCaught }
        let fishCounts = Dictionary(grouping: allFish) { $0 }
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        self.mostCommonFish = fishCounts.first?.key
        
        // Calculate best ice condition (most good results)
        let iceConditions = sessions.filter { $0.overallResult == .good }
            .map { $0.iceCondition }
        let iceCounts = Dictionary(grouping: iceConditions) { $0 }
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        self.bestIceCondition = iceCounts.first?.key
        
        // Find best day (most recent good result)
        self.bestDay = sessions
            .filter { $0.overallResult == .good }
            .sorted { $0.date > $1.date }
            .first?.date
        
        // Count results
        self.goodSessions = sessions.filter { $0.overallResult == .good }.count
        self.normalSessions = sessions.filter { $0.overallResult == .normal }.count
        self.poorSessions = sessions.filter { $0.overallResult == .poor }.count
    }
}
