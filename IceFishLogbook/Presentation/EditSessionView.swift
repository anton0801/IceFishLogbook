import SwiftUI

struct EditSessionView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: SessionViewModel
    
    let session: FishingSession
    
    @State private var date: Date
    @State private var location: String
    @State private var waterType: WaterType
    @State private var iceCondition: IceCondition
    @State private var selectedWeather: Set<WeatherCondition>
    @State private var selectedFish: Set<FishSpecies>
    @State private var overallResult: SessionResult
    @State private var notes: String
    
    @State private var showingSaveAnimation = false
    
    init(session: FishingSession) {
        self.session = session
        _date = State(initialValue: session.date)
        _location = State(initialValue: session.location)
        _waterType = State(initialValue: session.waterType)
        _iceCondition = State(initialValue: session.iceCondition)
        _selectedWeather = State(initialValue: Set(session.weather))
        _selectedFish = State(initialValue: Set(session.fishCaught))
        _overallResult = State(initialValue: session.overallResult)
        _notes = State(initialValue: session.notes)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient.iceBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        FormSection(title: "Date") {
                            DatePicker("Session Date", selection: $date, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                        }
                        
                        FormSection(title: "Location") {
                            TextField("Lake name, river, etc.", text: $location)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        FormSection(title: "Water Type") {
                            HStack(spacing: 12) {
                                ForEach(WaterType.allCases, id: \.self) { type in
                                    SelectionChip(
                                        title: type.rawValue,
                                        icon: type.icon,
                                        isSelected: waterType == type
                                    ) {
                                        withAnimation(.spring(response: 0.3)) {
                                            waterType = type
                                        }
                                    }
                                }
                            }
                        }
                        
                        FormSection(title: "Ice Conditions") {
                            HStack(spacing: 12) {
                                ForEach(IceCondition.allCases, id: \.self) { condition in
                                    SelectionChip(
                                        title: condition.rawValue,
                                        icon: condition.icon,
                                        isSelected: iceCondition == condition,
                                        color: Color(condition.color)
                                    ) {
                                        withAnimation(.spring(response: 0.3)) {
                                            iceCondition = condition
                                        }
                                    }
                                }
                            }
                        }
                        
                        FormSection(title: "Weather") {
                            VStack(spacing: 8) {
                                ForEach(Array(stride(from: 0, to: WeatherCondition.allCases.count, by: 2)), id: \.self) { index in
                                    HStack(spacing: 12) {
                                        ForEach(index..<min(index + 2, WeatherCondition.allCases.count), id: \.self) { i in
                                            let condition = WeatherCondition.allCases[i]
                                            MultiSelectChip(
                                                title: condition.rawValue,
                                                icon: condition.icon,
                                                isSelected: selectedWeather.contains(condition)
                                            ) {
                                                toggleWeather(condition)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        FormSection(title: "Fish Caught (Optional)") {
                            VStack(spacing: 8) {
                                ForEach(Array(stride(from: 0, to: FishSpecies.allCases.count, by: 2)), id: \.self) { index in
                                    HStack(spacing: 12) {
                                        ForEach(index..<min(index + 2, FishSpecies.allCases.count), id: \.self) { i in
                                            let fish = FishSpecies.allCases[i]
                                            MultiSelectChip(
                                                title: fish.rawValue,
                                                icon: "fish.fill",
                                                isSelected: selectedFish.contains(fish)
                                            ) {
                                                toggleFish(fish)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        FormSection(title: "Overall Result") {
                            HStack(spacing: 12) {
                                ForEach(SessionResult.allCases, id: \.self) { result in
                                    SelectionChip(
                                        title: result.rawValue,
                                        icon: result.icon,
                                        isSelected: overallResult == result,
                                        color: Color(result.color)
                                    ) {
                                        withAnimation(.spring(response: 0.3)) {
                                            overallResult = result
                                        }
                                    }
                                }
                            }
                        }
                        
                        FormSection(title: "Notes") {
                            TextEditor(text: $notes)
                                .frame(height: 120)
                                .padding(12)
                                .background(Color.snowWhite)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.winterGray.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                    .padding()
                }
                
                if showingSaveAnimation {
                    SaveAnimationOverlay()
                }
            }
            .navigationTitle("Edit Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.winterGray)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSession()
                    }
                    .foregroundColor(.frostBlue)
                    .fontWeight(.semibold)
                    .disabled(location.isEmpty)
                }
            }
        }
    }
    
    private func toggleWeather(_ condition: WeatherCondition) {
        withAnimation(.spring(response: 0.3)) {
            if selectedWeather.contains(condition) {
                selectedWeather.remove(condition)
            } else {
                selectedWeather.insert(condition)
            }
        }
    }
    
    private func toggleFish(_ fish: FishSpecies) {
        withAnimation(.spring(response: 0.3)) {
            if selectedFish.contains(fish) {
                selectedFish.remove(fish)
            } else {
                selectedFish.insert(fish)
            }
        }
    }
    
    private func saveSession() {
        var updatedSession = session
        updatedSession.date = date
        updatedSession.location = location
        updatedSession.waterType = waterType
        updatedSession.iceCondition = iceCondition
        updatedSession.weather = Array(selectedWeather)
        updatedSession.fishCaught = Array(selectedFish)
        updatedSession.overallResult = overallResult
        updatedSession.notes = notes
        
        viewModel.updateSession(updatedSession)
        
        showingSaveAnimation = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            presentationMode.wrappedValue.dismiss()
        }
    }
}
