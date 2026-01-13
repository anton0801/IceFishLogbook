import SwiftUI

struct AddSessionView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: SessionViewModel
    
    @State private var date = Date()
    @State private var location = ""
    @State private var waterType: WaterType = .lake
    @State private var iceCondition: IceCondition = .normal
    @State private var selectedWeather: Set<WeatherCondition> = []
    @State private var selectedFish: Set<FishSpecies> = []
    @State private var overallResult: SessionResult = .normal
    @State private var notes = ""
    
    @State private var showingSaveAnimation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient.iceBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Date picker
                        FormSection(title: "Date") {
                            DatePicker("Session Date", selection: $date, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                        }
                        
                        // Location
                        FormSection(title: "Location") {
                            TextField("Lake name, river, etc.", text: $location)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Water type
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
                        
                        // Ice condition
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
                        
                        // Weather
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
                        
                        // Fish caught
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
                        
                        // Overall result
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
                        
                        // Notes
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
                
                // Save animation overlay
                if showingSaveAnimation {
                    SaveAnimationOverlay()
                }
            }
            .navigationTitle("Add Session")
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
        let session = FishingSession(
            date: date,
            location: location,
            waterType: waterType,
            iceCondition: iceCondition,
            weather: Array(selectedWeather),
            fishCaught: Array(selectedFish),
            overallResult: overallResult,
            notes: notes
        )
        
        viewModel.addSession(session)
        
        // Show save animation
        showingSaveAnimation = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Form Section
struct FormSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.deepIce)
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Selection Chip
struct SelectionChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    var color: Color = .frostBlue
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? .snowWhite : color)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? color : Color.snowWhite)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(color, lineWidth: isSelected ? 0 : 1)
            )
            .shadow(color: isSelected ? color.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
    }
}

// MARK: - Multi-Select Chip
struct MultiSelectChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? .frostBlue : .winterGray)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.frostBlue.opacity(0.1) : Color.snowWhite)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.frostBlue : Color.winterGray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Custom Text Field Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(Color.snowWhite)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.winterGray.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - Save Animation Overlay
struct SaveAnimationOverlay: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.glacierGreen)
                
                Text("Session Saved!")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.deepIce)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.snowWhite)
            )
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

// MARK: - Preview
struct AddSessionView_Previews: PreviewProvider {
    static var previews: some View {
        AddSessionView()
            .environmentObject(SessionViewModel())
    }
}
