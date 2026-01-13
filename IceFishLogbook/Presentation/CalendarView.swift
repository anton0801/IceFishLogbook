import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var viewModel: SessionViewModel
    @State private var currentDate = Date()
    @State private var selectedDate: Date?
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient.iceBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Month selector
                    monthSelector
                    
                    // Calendar grid
                    calendarGrid
                    
                    // Sessions for selected date
                    if let selected = selectedDate {
                        selectedDateSessions(for: selected)
                    }
                }
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var monthSelector: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.frostBlue)
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            Text(dateFormatter.string(from: currentDate))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.deepIce)
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.frostBlue)
                    .frame(width: 44, height: 44)
            }
        }
        .padding()
        .background(Color.snowWhite)
    }
    
    private var calendarGrid: some View {
        VStack(spacing: 0) {
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { weekday in
                    Text(weekday)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.winterGray)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 12)
            .background(Color.snowWhite.opacity(0.5))
            
            // Calendar days
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
                ForEach(getDaysInMonth(), id: \.self) { date in
                    if let date = date {
                        CalendarDayView(
                            date: date,
                            isCurrentMonth: calendar.isDate(date, equalTo: currentDate, toGranularity: .month),
                            isSelected: selectedDate != nil && calendar.isDate(date, inSameDayAs: selectedDate!),
                            hasSession: viewModel.hasSessionOnDate(date),
                            resultColor: viewModel.getResultColorForDate(date)
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                if selectedDate != nil && calendar.isDate(date, inSameDayAs: selectedDate!) {
                                    selectedDate = nil
                                } else {
                                    selectedDate = date
                                }
                            }
                        }
                    } else {
                        Color.clear
                            .frame(height: 50)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func selectedDateSessions(for date: Date) -> some View {
        let sessions = viewModel.getSessionsForDate(date)
        
        return VStack(alignment: .leading, spacing: 16) {
            Divider()
            
            HStack {
                Text(formattedSelectedDate(date))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.deepIce)
                
                Spacer()
                
                Button(action: { selectedDate = nil }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.winterGray)
                }
            }
            .padding(.horizontal)
            
            if sessions.isEmpty {
                Text("No sessions on this day")
                    .font(.system(size: 15))
                    .foregroundColor(.winterGray)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(sessions) { session in
                            NavigationLink(destination: SessionDetailView(session: session)) {
                                CompactSessionCard(session: session)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .frame(maxHeight: 300)
        .background(Color.snowWhite)
    }
    
    private func getDaysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start)
        else {
            return []
        }
        
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentDate)?.count ?? 0
        let firstDayWeekday = calendar.component(.weekday, from: monthInterval.start)
        let leadingEmptyDays = firstDayWeekday - calendar.firstWeekday
        let adjustedLeadingDays = leadingEmptyDays >= 0 ? leadingEmptyDays : leadingEmptyDays + 7
        
        var days: [Date?] = Array(repeating: nil, count: adjustedLeadingDays)
        
        for day in 1...daysInMonth {
            if let date = calendar.date(bySetting: .day, value: day, of: monthInterval.start) {
                days.append(date)
            }
        }
        
        let totalCells = Int(ceil(Double(days.count) / 7.0)) * 7
        days.append(contentsOf: Array(repeating: nil, count: totalCells - days.count))
        
        return days
    }
    
    private func previousMonth() {
        withAnimation {
            if let newDate = calendar.date(byAdding: .month, value: -1, to: currentDate) {
                currentDate = newDate
                selectedDate = nil
            }
        }
    }
    
    private func nextMonth() {
        withAnimation {
            if let newDate = calendar.date(byAdding: .month, value: 1, to: currentDate) {
                currentDate = newDate
                selectedDate = nil
            }
        }
    }
    
    private func formattedSelectedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

// MARK: - Calendar Day View
struct CalendarDayView: View {
    let date: Date
    let isCurrentMonth: Bool
    let isSelected: Bool
    let hasSession: Bool
    let resultColor: SessionResult?
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                .foregroundColor(textColor)
            
            if hasSession, let result = resultColor {
                Circle()
                    .fill(Color(result.color))
                    .frame(width: 6, height: 6)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 6, height: 6)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.frostBlue.opacity(0.2) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.frostBlue : Color.clear, lineWidth: 2)
        )
    }
    
    private var textColor: Color {
        if !isCurrentMonth {
            return .winterGray.opacity(0.3)
        } else if isSelected {
            return .frostBlue
        } else if calendar.isDateInToday(date) {
            return .deepIce
        } else {
            return .deepIce.opacity(0.8)
        }
    }
}

// MARK: - Compact Session Card
struct CompactSessionCard: View {
    let session: FishingSession
    
    var body: some View {
        HStack(spacing: 12) {
            // Result indicator
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(session.overallResult.color))
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(session.location)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.deepIce)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Label(session.waterType.rawValue, systemImage: session.waterType.icon)
                        .font(.system(size: 12))
                        .foregroundColor(.winterGray)
                    
                    if !session.fishCaught.isEmpty {
                        HStack(spacing: 2) {
                            Image(systemName: "fish.fill")
                            Text("\(session.fishCaught.count)")
                        }
                        .font(.system(size: 12))
                        .foregroundColor(.glacierGreen)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.winterGray.opacity(0.5))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.iceBackground)
        )
    }
}

// MARK: - Preview
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
            .environmentObject(SessionViewModel())
    }
}
