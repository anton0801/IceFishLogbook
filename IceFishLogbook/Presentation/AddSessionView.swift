import SwiftUI

struct AddSessionView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var date = Date()
    @State private var location = ""
    @State private var waterType = "Lake"
    @State private var iceConditions = "Normal"
    @State private var weather = "Cold"
    @State private var fishCaughtString = ""
    @State private var overallResult = "Normal"
    @State private var notes = ""
    
    let onSave: (FishingSession) -> Void
    
    let waterTypes = ["Lake", "River", "Reservoir"]
    let iceConditionsOptions = ["Thin", "Normal", "Thick"]
    let weatherOptions = ["Cold", "Windy", "Snow", "Clear"]
    let resultOptions = ["Poor", "Normal", "Good"]
    
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
            .navigationTitle("Add Session")
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
                        let newSession = FishingSession(date: date, location: location, waterType: waterType, iceConditions: iceConditions, weather: weather, fishCaught: fish, overallResult: overallResult, notes: notes)
                        onSave(newSession)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(location.isEmpty)
                }
            }
            .background(Color.blue.opacity(0.05).ignoresSafeArea())
        }
    }
}
