import Foundation
import Combine

class SessionViewModel: ObservableObject {
    
    @Published var sessions: [FishingSession] = []
    @Published var filteredSessions: [FishingSession] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var stats: FishingStats?
    
    // Filters
    @Published var selectedFishFilter: FishSpecies?
    @Published var selectedResultFilter: SessionResult?
    @Published var selectedWaterTypeFilter: WaterType?
    @Published var searchText: String = ""
    
    private var firebaseService = FirebaseService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupObservers()
        loadSessions()
    }
    
    private func setupObservers() {
        // Observe Firebase sessions
        firebaseService.$sessions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessions in
                self?.sessions = sessions
                self?.applyFilters()
                self?.calculateStats()
            }
            .store(in: &cancellables)
        
        // Observe filter changes
        Publishers.CombineLatest4(
            $selectedFishFilter,
            $selectedResultFilter,
            $selectedWaterTypeFilter,
            $searchText
        )
        .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
        .sink { [weak self] _ in
            self?.applyFilters()
        }
        .store(in: &cancellables)
    }
    
    func loadSessions() {
        isLoading = true
        
        firebaseService.fetchSessions { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let sessions):
                    self?.sessions = sessions
                    self?.applyFilters()
                    self?.calculateStats()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Session Management
    func addSession(_ session: FishingSession) {
        isLoading = true
        
        firebaseService.saveSession(session) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    break // Firebase observer will update automatically
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func updateSession(_ session: FishingSession) {
        isLoading = true
        
        firebaseService.updateSession(session) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    break // Firebase observer will update automatically
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func deleteSession(_ session: FishingSession) {
        isLoading = true
        
        firebaseService.deleteSession(session.id) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    break // Firebase observer will update automatically
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Filtering
    private func applyFilters() {
        var filtered = sessions
        
        // Fish filter
        if let fishFilter = selectedFishFilter {
            filtered = filtered.filter { $0.fishCaught.contains(fishFilter) }
        }
        
        // Result filter
        if let resultFilter = selectedResultFilter {
            filtered = filtered.filter { $0.overallResult == resultFilter }
        }
        
        // Water type filter
        if let waterTypeFilter = selectedWaterTypeFilter {
            filtered = filtered.filter { $0.waterType == waterTypeFilter }
        }
        
        // Search filter
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.location.lowercased().contains(searchText.lowercased()) ||
                $0.notes.lowercased().contains(searchText.lowercased())
            }
        }
        
        filteredSessions = filtered
    }
    
    func clearFilters() {
        selectedFishFilter = nil
        selectedResultFilter = nil
        selectedWaterTypeFilter = nil
        searchText = ""
    }
    
    // MARK: - Statistics
    private func calculateStats() {
        stats = FishingStats(sessions: sessions)
    }
    
    func getFishFrequency() -> [(FishSpecies, Int)] {
        let allFish = sessions.flatMap { $0.fishCaught }
        let fishCounts = Dictionary(grouping: allFish) { $0 }
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        
        return fishCounts.map { ($0.key, $0.value) }
    }
    
    func getSessionsForFish(_ fish: FishSpecies) -> [FishingSession] {
        return sessions.filter { $0.fishCaught.contains(fish) }
    }
    
    // MARK: - Calendar Data
    func getSessionsForDate(_ date: Date) -> [FishingSession] {
        return sessions.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func hasSessionOnDate(_ date: Date) -> Bool {
        return sessions.contains { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func getResultColorForDate(_ date: Date) -> SessionResult? {
        let sessionsOnDate = getSessionsForDate(date)
        guard !sessionsOnDate.isEmpty else { return nil }
        
        // Return the best result of the day
        if sessionsOnDate.contains(where: { $0.overallResult == .good }) {
            return .good
        } else if sessionsOnDate.contains(where: { $0.overallResult == .normal }) {
            return .normal
        } else {
            return .poor
        }
    }
    
    // MARK: - Export
    func exportToCSV() -> String {
        var csv = "Date,Location,Water Type,Ice Condition,Weather,Fish Caught,Result,Notes\n"
        
        for session in sessions.sorted(by: { $0.date < $1.date }) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            
            let date = dateFormatter.string(from: session.date)
            let location = session.location.replacingOccurrences(of: ",", with: ";")
            let waterType = session.waterType.rawValue
            let iceCondition = session.iceCondition.rawValue
            let weather = session.weather.map { $0.rawValue }.joined(separator: "; ")
            let fish = session.fishCaught.map { $0.rawValue }.joined(separator: "; ")
            let result = session.overallResult.rawValue
            let notes = session.notes.replacingOccurrences(of: ",", with: ";").replacingOccurrences(of: "\n", with: " ")
            
            csv += "\(date),\(location),\(waterType),\(iceCondition),\(weather),\(fish),\(result),\(notes)\n"
        }
        
        return csv
    }
    
    // MARK: - Data Reset
    func resetAllData(completion: @escaping (Bool) -> Void) {
        firebaseService.resetAllData { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    completion(true)
                case .failure:
                    completion(false)
                }
            }
        }
    }
}
