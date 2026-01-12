import SwiftUI

struct EditSessionView: View {
    let session: FishingSession
    let onSave: (FishingSession) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var date: Date
    @State private var location: String
    @State private var waterType: String
    @State private var iceConditions: String
    @State private var weather: String
    @State private var fishCaughtString: String
    @State private var overallResult: String
    @State private var notes: String
    
    let waterTypes = ["Lake", "River", "Reservoir"]
    let iceConditionsOptions = ["Thin", "Normal", "Thick"]
    let weatherOptions = ["Cold", "Windy", "Snow", "Clear"]
    let resultOptions = ["Poor", "Normal", "Good"]
    
    init(session: FishingSession, onSave: @escaping (FishingSession) -> Void) {
        self.session = session
        self.onSave = onSave
        _date = State(initialValue: session.date)
        _location = State(initialValue: session.location)
        _waterType = State(initialValue: session.waterType)
        _iceConditions = State(initialValue: session.iceConditions)
        _weather = State(initialValue: session.weather)
        _fishCaughtString = State(initialValue: session.fishCaught.joined(separator: ", "))
        _overallResult = State(initialValue: session.overallResult)
        _notes = State(initialValue: session.notes)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Date & Location").font(.subheadline).foregroundColor(.gray)) {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Location", text: $location)
                        .textContentType(.location)
                }
                
                Section(header: Text("Conditions").font(.subheadline).foregroundColor(.gray)) {
                    Picker("Water Type", selection: $waterType) {
                        ForEach(waterTypes, id: \.self) { Text($0) }
                    }
                    Picker("Ice Conditions", selection: $iceConditions) {
                        ForEach(iceConditionsOptions, id: \.self) { Text($0) }
                    }
                    Picker("Weather", selection: $weather) {
                        ForEach(weatherOptions, id: \.self) { Text($0) }
                    }
                }
                
                Section(header: Text("Catch & Notes").font(.subheadline).foregroundColor(.gray)) {
                    TextField("Fish Caught (comma-separated)", text: $fishCaughtString)
                    Picker("Overall Result", selection: $overallResult) {
                        ForEach(resultOptions, id: \.self) { Text($0) }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Edit Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let fish = fishCaughtString.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                        var updatedSession = session
                        updatedSession.date = date
                        updatedSession.location = location
                        updatedSession.waterType = waterType
                        updatedSession.iceConditions = iceConditions
                        updatedSession.weather = weather
                        updatedSession.fishCaught = fish
                        updatedSession.overallResult = overallResult
                        updatedSession.notes = notes
                        onSave(updatedSession)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(location.isEmpty)
                }
            }
            .background(Color.blue.opacity(0.05).ignoresSafeArea())
        }
    }
}
