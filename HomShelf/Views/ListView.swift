import SwiftUI

struct ListView: View {
    @EnvironmentObject var store: ItemStore
    @State private var selectedDate: Date = Date()
    @State private var showDatePicker = false
    @State private var filterByDate = true
    @State private var selectedAction = "All"
    
    let actions = ["All", "Added", "Refilled", "Deleted"]
    
    // Group activity log by date
    var groupedActivities: [(String, [ActivityLog])] {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        
        // Filter by date if selected
        let dateFiltered = filterByDate ?
            store.activityLog.filter {
                Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
            } :
            store.activityLog
        
        // Filter by action
        let filtered = selectedAction == "All" ?
            dateFiltered :
            dateFiltered.filter { $0.action == selectedAction }
        
        var groups: [String: [ActivityLog]] = [:]
        for entry in filtered {
            let dateKey = formatter.string(from: entry.date)
            if groups[dateKey] == nil {
                groups[dateKey] = []
            }
            groups[dateKey]?.append(entry)
        }
        
        return groups.sorted { a, b in
            let df = DateFormatter()
            df.dateStyle = .long
            let date1 = df.date(from: a.0) ?? Date()
            let date2 = df.date(from: b.0) ?? Date()
            return date1 > date2
        }
    }
    
    // Color for action badges
    func actionColor(_ action: String) -> Color {
        switch action {
        case "Added": return .blue
        case "Refilled": return .orange
        case "Deleted": return .red
        default: return .green
        }
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.98, blue: 0.95)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // Header
                HStack {
                    Text("Shopping Journal")
                        .font(.system(size: 24, weight: .bold))
                    Spacer()
                    // Date filter button
                    Button(action: {
                        showDatePicker = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 14))
                            Text(filterByDate ? "Filtered" : "All Dates")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(filterByDate ? .white : .green)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(filterByDate ? Color.green : Color.green.opacity(0.1))
                        .cornerRadius(20)
                    }
                }
                .padding()
                
                // Action Filter Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(actions, id: \.self) { action in
                            Button(action: {
                                selectedAction = action
                            }) {
                                Text(action)
                                    .font(.system(size: 14, weight: .medium))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedAction == action ?
                                        actionColor(action) :
                                        Color.white
                                    )
                                    .foregroundColor(
                                        selectedAction == action ?
                                            .white : .black
                                    )
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                
                if store.activityLog.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "cart.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green.opacity(0.5))
                        Text("No Activity Yet")
                            .font(.system(size: 22, weight: .bold))
                        Text("Add items to your Wardboard\nto see your shopping history here")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else if groupedActivities.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 60))
                            .foregroundColor(.orange.opacity(0.5))
                        Text("No Activity Found")
                            .font(.system(size: 20, weight: .bold))
                        Text("Try selecting a different date\nor change the filter")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(groupedActivities, id: \.0) { dateString, entries in
                                VStack(alignment: .leading, spacing: 0) {
                                    
                                    // Date Header
                                    HStack(spacing: 8) {
                                        Image(systemName: "calendar.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.system(size: 18))
                                        Text(dateString)
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(.black)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.green.opacity(0.08))
                                    .cornerRadius(12)
                                    
                                    // Entries
                                    VStack(spacing: 0) {
                                        ForEach(entries) { entry in
                                            HStack(spacing: 12) {
                                                
                                                // Emoji circle
                                                ZStack {
                                                    Circle()
                                                        .fill(actionColor(entry.action).opacity(0.1))
                                                        .frame(width: 44, height: 44)
                                                    Text(entry.emoji)
                                                        .font(.system(size: 20))
                                                }
                                                
                                                // Name and action
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(entry.itemName)
                                                        .font(.system(size: 15, weight: .semibold))
                                                        .foregroundColor(.black)
                                                    HStack(spacing: 4) {
                                                        Text(entry.action)
                                                            .font(.system(size: 12, weight: .medium))
                                                            .foregroundColor(actionColor(entry.action))
                                                            .padding(.horizontal, 8)
                                                            .padding(.vertical, 2)
                                                            .background(actionColor(entry.action).opacity(0.1))
                                                            .cornerRadius(8)
                                                        Text(entry.quantity)
                                                            .font(.system(size: 12))
                                                            .foregroundColor(.gray)
                                                    }
                                                }
                                                
                                                Spacer()
                                                
                                                // Price
                                                Text("$\(entry.price, specifier: "%.2f")")
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(.black)
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 10)
                                            
                                            if entry.id != entries.last?.id {
                                                Divider()
                                                    .padding(.leading, 68)
                                            }
                                        }
                                    }
                                    .background(Color.white)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        // Date Picker Sheet
        .sheet(isPresented: $showDatePicker) {
            NavigationView {
                ZStack {
                    Color(red: 0.95, green: 0.98, blue: 0.95)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 24) {
                        DatePicker(
                            "Select Date",
                            selection: $selectedDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .tint(.green)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding()
                        
                        Button(action: {
                            filterByDate = true
                            showDatePicker = false
                        }) {
                            Text("Show This Date")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(30)
                                .padding(.horizontal)
                        }
                        
                        Button(action: {
                            filterByDate = false
                            showDatePicker = false
                        }) {
                            Text("Show All Dates")
                                .font(.system(size: 16))
                                .foregroundColor(.green)
                        }
                        
                        Spacer()
                    }
                }
                .navigationTitle("Filter by Date")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { showDatePicker = false }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.black)
                        }
                    }
                }
            }
        }
    }
}
