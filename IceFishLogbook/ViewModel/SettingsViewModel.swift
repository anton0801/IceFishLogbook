import Foundation
import Combine

//class SettingsViewModel: ObservableObject {
//    @Published var unitPreference: UnitPreference = .metric
//    @Published var showResetConfirmation = false
//    
//    init() {
//        loadPreferences()
//    }
//    
//    func loadPreferences() {
//        if let data = UserDefaults.standard.data(forKey: "unitPreference"),
//           let preference = try? JSONDecoder().decode(UnitPreference.self, from: data) {
//            unitPreference = preference
//        }
//    }
//    
//    func savePreferences() {
//        if let data = try? JSONEncoder().encode(unitPreference) {
//            UserDefaults.standard.set(data, forKey: "unitPreference")
//        }
//    }
//    
//    func resetAllData() {
//        StorageService.shared.deleteAllSessions()
//        FirebaseService.shared.deleteAllRemoteData { error in
//            if let error = error {
//                print("Error deleting remote data: \(error)")
//            }
//        }
//    }
//}
