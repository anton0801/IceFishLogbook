import Foundation
import Combine

//class CalendarViewModel: ObservableObject {
//    @Published var currentMonth: Date = Date()
//    @Published var selectedDate: Date?
//    @Published var sessionsForMonth: [FishingSession] = []
//    @Published var sessionsForSelectedDate: [FishingSession] = []
//    
//    private let storageService = StorageService.shared
//    private var cancellables = Set<AnyCancellable>()
//    
//    init() {
//        setupObservers()
//        loadSessionsForMonth()
//    }
//    
//    private func setupObservers() {
//        storageService.$sessions
//            .sink { [weak self] _ in
//                self?.loadSessionsForMonth()
//                if let selectedDate = self?.selectedDate {
//                    self?.loadSessionsForDate(selectedDate)
//                }
//            }
//            .store(in: &cancellables)
//        
//        $currentMonth
//            .sink { [weak self] _ in
//                self?.loadSessionsForMonth()
//            }
//            .store(in: &cancellables)
//        
//        $selectedDate
//            .sink { [weak self] date in
//                if let date = date {
//                    self?.loadSessionsForDate(date)
//                } else {
//                    self?.sessionsForSelectedDate = []
//                }
//            }
//            .store(in: &cancellables)
//    }
//    
//    func loadSessionsForMonth() {
//        sessionsForMonth = storageService.getSessionsForMonth(currentMonth)
//    }
//    
//    func loadSessionsForDate(_ date: Date) {
//        sessionsForSelectedDate = storageService.getSessionsForDate(date)
//    }
//    
//    func goToPreviousMonth() {
//        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) {
//            currentMonth = newDate
//        }
//    }
//    
//    func goToNextMonth() {
//        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) {
//            currentMonth = newDate
//        }
//    }
//    
//    func goToToday() {
//        currentMonth = Date()
//        selectedDate = Date()
//    }
//    
//    func getSessionForDate(_ date: Date) -> FishingSession? {
//        sessionsForMonth.first { $0.date.isSameDay(as: date) }
//    }
//    
//    func hasSessionOnDate(_ date: Date) -> Bool {
//        sessionsForMonth.contains { $0.date.isSameDay(as: date) }
//    }
//}
