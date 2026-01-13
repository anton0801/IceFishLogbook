import Foundation
import FirebaseDatabase


struct FishingSession: Identifiable, Codable {
    var id: String
    var date: Date
    var location: String
    var waterType: WaterType
    var iceCondition: IceCondition
    var weather: [WeatherCondition]
    var fishCaught: [FishSpecies]
    var overallResult: SessionResult
    var notes: String
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        date: Date = Date(),
        location: String = "",
        waterType: WaterType = .lake,
        iceCondition: IceCondition = .normal,
        weather: [WeatherCondition] = [],
        fishCaught: [FishSpecies] = [],
        overallResult: SessionResult = .normal,
        notes: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.location = location
        self.waterType = waterType
        self.iceCondition = iceCondition
        self.weather = weather
        self.fishCaught = fishCaught
        self.overallResult = overallResult
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Convert to dictionary for Firebase
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "date": date.timeIntervalSince1970,
            "location": location,
            "waterType": waterType.rawValue,
            "iceCondition": iceCondition.rawValue,
            "weather": weather.map { $0.rawValue },
            "fishCaught": fishCaught.map { $0.rawValue },
            "overallResult": overallResult.rawValue,
            "notes": notes,
            "createdAt": createdAt.timeIntervalSince1970,
            "updatedAt": updatedAt.timeIntervalSince1970
        ]
    }
    
    // Create from Firebase snapshot
    static func fromSnapshot(_ snapshot: DataSnapshot) -> FishingSession? {
        guard let dict = snapshot.value as? [String: Any],
              let id = dict["id"] as? String,
              let dateTimestamp = dict["date"] as? TimeInterval,
              let location = dict["location"] as? String,
              let waterTypeRaw = dict["waterType"] as? String,
              let iceConditionRaw = dict["iceCondition"] as? String,
              let weatherRaw = dict["weather"] as? [String],
              let fishCaughtRaw = dict["fishCaught"] as? [String],
              let resultRaw = dict["overallResult"] as? String,
              let notes = dict["notes"] as? String,
              let createdTimestamp = dict["createdAt"] as? TimeInterval,
              let updatedTimestamp = dict["updatedAt"] as? TimeInterval
        else {
            return nil
        }
        
        let waterType = WaterType(rawValue: waterTypeRaw) ?? .lake
        let iceCondition = IceCondition(rawValue: iceConditionRaw) ?? .normal
        let weather = weatherRaw.compactMap { WeatherCondition(rawValue: $0) }
        let fishCaught = fishCaughtRaw.compactMap { FishSpecies(rawValue: $0) }
        let result = SessionResult(rawValue: resultRaw) ?? .normal
        
        return FishingSession(
            id: id,
            date: Date(timeIntervalSince1970: dateTimestamp),
            location: location,
            waterType: waterType,
            iceCondition: iceCondition,
            weather: weather,
            fishCaught: fishCaught,
            overallResult: result,
            notes: notes,
            createdAt: Date(timeIntervalSince1970: createdTimestamp),
            updatedAt: Date(timeIntervalSince1970: updatedTimestamp)
        )
    }
}
