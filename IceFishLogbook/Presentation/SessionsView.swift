import SwiftUI

struct SessionsListView: View {
    @EnvironmentObject var viewModel: SessionViewModel
    @State private var showingFilters = false
    @State private var showingAddSession = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient.iceBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    searchBar
                    
                    // Filter chips
                    if hasActiveFilters {
                        activeFiltersView
                    }
                    
                    // Sessions list
                    if viewModel.filteredSessions.isEmpty {
                        emptyStateView
                    } else {
                        sessionsList
                    }
                }
            }
            .navigationTitle("All Sessions")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingFilters = true }) {
                            Label("Filter & Sort", systemImage: "line.3.horizontal.decrease.circle")
                        }
                        
                        Button(action: { showingAddSession = true }) {
                            Label("Add Session", systemImage: "plus.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.frostBlue)
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                FiltersView()
            }
            .sheet(isPresented: $showingAddSession) {
                AddSessionView()
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.winterGray)
            
            TextField("Search location or notes...", text: $viewModel.searchText)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.winterGray)
                }
            }
        }
        .padding(12)
        .background(Color.snowWhite)
        .cornerRadius(12)
        .padding()
    }
    
    private var hasActiveFilters: Bool {
        viewModel.selectedFishFilter != nil ||
        viewModel.selectedResultFilter != nil ||
        viewModel.selectedWaterTypeFilter != nil
    }
    
    private var activeFiltersView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if let filter = viewModel.selectedFishFilter {
                    FilterChipView(title: filter.rawValue, icon: "fish.fill") {
                        viewModel.selectedFishFilter = nil
                    }
                }
                
                if let filter = viewModel.selectedResultFilter {
                    FilterChipView(title: filter.rawValue, icon: filter.icon) {
                        viewModel.selectedResultFilter = nil
                    }
                }
                
                if let filter = viewModel.selectedWaterTypeFilter {
                    FilterChipView(title: filter.rawValue, icon: filter.icon) {
                        viewModel.selectedWaterTypeFilter = nil
                    }
                }
                
                Button(action: { viewModel.clearFilters() }) {
                    Text("Clear All")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.red.opacity(0.1))
                        )
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
    
    private var sessionsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredSessions) { session in
                    NavigationLink(destination: SessionDetailView(session: session)) {
                        SessionCardView(session: session)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: hasActiveFilters ? "line.3.horizontal.decrease.circle" : "tray")
                .font(.system(size: 60))
                .foregroundColor(.winterGray.opacity(0.5))
            
            Text(hasActiveFilters ? "No matching sessions" : "No sessions yet")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.winterGray)
            
            Text(hasActiveFilters ? "Try adjusting your filters" : "Start logging your ice fishing trips")
                .font(.system(size: 15))
                .foregroundColor(.winterGray.opacity(0.8))
            
            if hasActiveFilters {
                Button(action: { viewModel.clearFilters() }) {
                    Text("Clear Filters")
                        .fontWeight(.semibold)
                        .foregroundColor(.frostBlue)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.frostBlue.opacity(0.1))
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Filter Chip View
struct FilterChipView: View {
    let title: String
    let icon: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(title)
                .font(.system(size: 13, weight: .medium))
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
            }
        }
        .foregroundColor(.frostBlue)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.frostBlue.opacity(0.15))
        )
    }
}

// MARK: - Filters View
struct FiltersView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: SessionViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient.iceBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Fish filter
                        FilterSection(title: "Fish Species") {
                            VStack(spacing: 8) {
                                ForEach(FishSpecies.allCases, id: \.self) { fish in
                                    FilterOptionRow(
                                        title: fish.rawValue,
                                        icon: "fish.fill",
                                        isSelected: viewModel.selectedFishFilter == fish
                                    ) {
                                        viewModel.selectedFishFilter = viewModel.selectedFishFilter == fish ? nil : fish
                                    }
                                }
                            }
                        }
                        
                        // Result filter
                        FilterSection(title: "Session Result") {
                            VStack(spacing: 8) {
                                ForEach(SessionResult.allCases, id: \.self) { result in
                                    FilterOptionRow(
                                        title: result.rawValue,
                                        icon: result.icon,
                                        isSelected: viewModel.selectedResultFilter == result,
                                        color: Color(result.color)
                                    ) {
                                        viewModel.selectedResultFilter = viewModel.selectedResultFilter == result ? nil : result
                                    }
                                }
                            }
                        }
                        
                        // Water type filter
                        FilterSection(title: "Water Type") {
                            VStack(spacing: 8) {
                                ForEach(WaterType.allCases, id: \.self) { type in
                                    FilterOptionRow(
                                        title: type.rawValue,
                                        icon: type.icon,
                                        isSelected: viewModel.selectedWaterTypeFilter == type
                                    ) {
                                        viewModel.selectedWaterTypeFilter = viewModel.selectedWaterTypeFilter == type ? nil : type
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear All") {
                        viewModel.clearFilters()
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.frostBlue)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Filter Section
struct FilterSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.deepIce)
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Filter Option Row
struct FilterOptionRow: View {
    let title: String
    let icon: String
    let isSelected: Bool
    var color: Color = .frostBlue
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? color : .winterGray)
                    .frame(width: 32)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? color : .deepIce)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(color)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? color.opacity(0.1) : Color.snowWhite)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Preview
struct SessionsListView_Previews: PreviewProvider {
    static var previews: some View {
        SessionsListView()
            .environmentObject(SessionViewModel())
    }
}
