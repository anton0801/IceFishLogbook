import Foundation
import FirebaseDatabase

// MARK: - Enums
enum WaterType: String, Codable, CaseIterable {
    case lake = "Lake"
    case river = "River"
    case reservoir = "Reservoir"
    
    var icon: String {
        switch self {
        case .lake: return "drop.fill"
        case .river: return "water.waves"
        case .reservoir: return "rectangle.stack.fill"
        }
    }
}

enum IceCondition: String, Codable, CaseIterable {
    case thin = "Thin"
    case normal = "Normal"
    case thick = "Thick"
    
    var icon: String {
        switch self {
        case .thin: return "square.dashed"
        case .normal: return "square"
        case .thick: return "square.fill"
        }
    }
    
    var color: String {
        switch self {
        case .thin: return "resultPoor"
        case .normal: return "resultNormal"
        case .thick: return "resultGood"
        }
    }
}

enum WeatherCondition: String, Codable, CaseIterable {
    case cold = "Cold"
    case windy = "Windy"
    case snow = "Snow"
    case clear = "Clear"
    
    var icon: String {
        switch self {
        case .cold: return "thermometer.snowflake"
        case .windy: return "wind"
        case .snow: return "cloud.snow.fill"
        case .clear: return "sun.max.fill"
        }
    }
}

enum FishSpecies: String, Codable, CaseIterable {
    case perch = "Perch"
    case pike = "Pike"
    case walleye = "Walleye"
    case trout = "Trout"
    case bass = "Bass"
    case crappie = "Crappie"
    case bluegill = "Bluegill"
    case other = "Other"
    
    var icon: String {
        return "🐟"
    }
    
    var emoji: String {
        switch self {
        case .perch: return "🐟"
        case .pike: return "🐠"
        case .walleye: return "🐡"
        case .trout: return "🎣"
        case .bass: return "🐟"
        case .crappie: return "🐠"
        case .bluegill: return "🐡"
        case .other: return "🐟"
        }
    }
}

enum SessionResult: String, Codable, CaseIterable {
    case poor = "Poor"
    case normal = "Normal"
    case good = "Good"
    
    var color: String {
        switch self {
        case .poor: return "resultPoor"
        case .normal: return "resultNormal"
        case .good: return "resultGood"
        }
    }
    
    var icon: String {
        switch self {
        case .poor: return "hand.thumbsdown.fill"
        case .normal: return "hand.thumbsup"
        case .good: return "hand.thumbsup.fill"
        }
    }
}

