import Foundation
import Combine

//class StatsViewModel: ObservableObject {
//    @Published var statistics: SessionStatistics?
//    @Published var fishOverview: [(fish: FishSpecies, count: Int)] = []
//    
//    private let storageService = StorageService.shared
//    private var cancellables = Set<AnyCancellable>()
//    
//    init() {
//        setupObservers()
//        loadStatistics()
//    }
//    
//    private func setupObservers() {
//        storageService.$sessions
//            .sink { [weak self] _ in
//                self?.loadStatistics()
//            }
//            .store(in: &cancellables)
//    }
//    
//    func loadStatistics() {
//        statistics = storageService.getStatistics()
//        
//        let allFish = storageService.sessions.flatMap { $0.fishCaught }
//        let fishCounts = Dictionary(grouping: allFish, by: { $0 })
//            .mapValues { $0.count }
//            .sorted { $0.value > $1.value }
//        
//        fishOverview = fishCounts.map { (fish: $0.key, count: $0.value) }
//    }
//}
