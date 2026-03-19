import SwiftUI
import UserNotifications

struct ProfileView: View {
    @EnvironmentObject var store: ItemStore
    @State private var notificationsEnabled = true
    @State private var showNameEdit = false
    @State private var userName = "HomShelf User"
    @State private var tempName = ""
    @State private var showAbout = false
    @State private var tagline = "Managing your pantry smartly 🏠"
    @State private var showTaglineEdit = false
    @State private var tempTagline = ""
    @State private var showLowStock = false
    @State private var showAllItems = false
    @State private var showSpending = false
    @State private var showCategories = false
    @State private var spendingDate: Date = Date()
    @State private var filterSpendingByDate = false
    @State private var showSpendingDatePicker = false
    
    var totalItems: Int { store.items.count }
    var lowStockItems: Int { store.items.filter { $0.percentageLeft <= 20 }.count }
    var totalCategories: Int { Set(store.items.map { $0.category }).count }
    var totalSpent: Double { store.activityLog.reduce(0) { $0 + $1.price } }
    
    var latestDate: Date {
        store.activityLog.map { $0.date }.max() ?? Date()
    }
    
    func getMonthlySpending() -> [(String, Double, [ActivityLog])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        
        let filtered = filterSpendingByDate ?
            store.activityLog.filter {
                Calendar.current.isDate($0.date, inSameDayAs: spendingDate)
            } : store.activityLog
        
        var groups: [String: [ActivityLog]] = [:]
        for log in filtered {
            let key = formatter.string(from: log.date)
            if groups[key] == nil { groups[key] = [] }
            groups[key]?.append(log)
        }
        
        return groups.map { key, logs in
            let total = logs.reduce(0) { $0 + $1.price }
            return (key, total, logs)
        }
        .sorted { a, b in
            let df = DateFormatter()
            df.dateFormat = "MMMM yyyy"
            let date1 = df.date(from: a.0) ?? Date()
            let date2 = df.date(from: b.0) ?? Date()
            return date1 > date2
        }
    }
    
    var categoriesWithCount: [(String, Int)] {
        let cats = Set(store.items.map { $0.category })
        return cats.map { cat in
            (cat, store.items.filter { $0.category == cat }.count)
        }.sorted { $0.0 < $1.0 }
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.98, blue: 0.95)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    
                    // Header
                    HStack {
                        Text("Profile")
                            .font(.system(size: 24, weight: .bold))
                        Spacer()
                    }
                    .padding()
                    
                    // Profile Card
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.2))
                                .frame(width: 90, height: 90)
                            Image(systemName: "person.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.green)
                        }
                        
                        Text(userName)
                            .font(.system(size: 20, weight: .bold))
                        
                        Button(action: {
                            tempTagline = tagline
                            showTaglineEdit = true
                        }) {
                            Text(tagline)
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: {
                            tempName = userName
                            showNameEdit = true
                        }) {
                            Text("Edit Name")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.green)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(20)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    // App Stats Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("My Pantry Stats")
                            .font(.system(size: 16, weight: .bold))
                            .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            Button(action: { showAllItems = true }) {
                                StatBox(value: "\(totalItems)", label: "Total Items", color: .blue, icon: "cart.fill")
                            }
                            Button(action: { showLowStock = true }) {
                                StatBox(value: "\(lowStockItems)", label: "Low Stock", color: .red, icon: "exclamationmark.triangle.fill")
                            }
                        }
                        
                        HStack(spacing: 12) {
                            Button(action: { showCategories = true }) {
                                StatBox(value: "\(totalCategories)", label: "Categories", color: .purple, icon: "tag.fill")
                            }
                            Button(action: {
                                spendingDate = latestDate
                                filterSpendingByDate = false
                                showSpending = true
                            }) {
                                StatBox(value: "$\(String(format: "%.0f", totalSpent))", label: "Total Spent", color: .green, icon: "dollarsign.circle.fill")
                            }
                        }
                    }
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    // Settings List
                    VStack(spacing: 0) {
                        HStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.green.opacity(0.15))
                                    .frame(width: 32, height: 32)
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 14))
                            }
                            Text("Notifications")
                                .font(.system(size: 16))
                            Spacer()
                            Toggle("", isOn: $notificationsEnabled)
                                .tint(.green)
                                .onChange(of: notificationsEnabled) {
                                    if notificationsEnabled {
                                        NotificationManager.shared.requestPermission()
                                        NotificationManager.shared.scheduleDailyCheck(for: store.items)
                                    } else {
                                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                                    }
                                }
                        }
                        .padding()
                        
                        Divider().padding(.leading, 56)
                        SettingsRow(icon: "lock.fill", title: "Privacy", color: .blue)
                        Divider().padding(.leading, 56)
                        SettingsRow(icon: "questionmark.circle.fill", title: "Help & Support", color: .orange)
                        Divider().padding(.leading, 56)
                        
                        Button(action: { showAbout = true }) {
                            HStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.purple.opacity(0.15))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.purple)
                                        .font(.system(size: 14))
                                }
                                Text("About HomShelf")
                                    .font(.system(size: 16))
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))
                            }
                            .padding()
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    Text("HomShelf v1.0.0")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                    
                    Spacer().frame(height: 20)
                }
            }
        }
        
        // Edit Name Alert
        .alert("Edit Name", isPresented: $showNameEdit) {
            TextField("Your name", text: $tempName)
            Button("Save") { if !tempName.isEmpty { userName = tempName } }
            Button("Cancel", role: .cancel) {}
        } message: { Text("Enter your name") }
        
        // Edit Tagline Alert
        .alert("Edit Tagline", isPresented: $showTaglineEdit) {
            TextField("Your tagline", text: $tempTagline)
            Button("Save") { if !tempTagline.isEmpty { tagline = tempTagline } }
            Button("Cancel", role: .cancel) {}
        } message: { Text("Enter your tagline") }
        
        // All Items Sheet
        .sheet(isPresented: $showAllItems) {
            NavigationView {
                ZStack {
                    Color(red: 0.95, green: 0.98, blue: 0.95).ignoresSafeArea()
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(store.items) { item in
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.blue.opacity(0.1))
                                            .frame(width: 44, height: 44)
                                        Text(item.displayEmoji)
                                            .font(.system(size: 22))
                                    }
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.name)
                                            .font(.system(size: 15, weight: .semibold))
                                        Text(item.category)
                                            .font(.system(size: 13))
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Text("\(Int(item.percentageLeft))% left")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(
                                            item.percentageLeft > 50 ? .green :
                                            item.percentageLeft > 20 ? .orange : .red
                                        )
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(16)
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top)
                    }
                }
                .navigationTitle("All Items (\(totalItems))")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { showAllItems = false }) {
                            Image(systemName: "arrow.left").foregroundColor(.black)
                        }
                    }
                }
            }
        }
        
        // Low Stock Sheet
        .sheet(isPresented: $showLowStock) {
            NavigationView {
                ZStack {
                    Color(red: 0.95, green: 0.98, blue: 0.95).ignoresSafeArea()
                    ScrollView {
                        VStack(spacing: 12) {
                            if store.items.filter({ $0.percentageLeft <= 20 }).isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.green.opacity(0.5))
                                    Text("All items are well stocked!")
                                        .font(.system(size: 18, weight: .bold))
                                }
                                .padding(.top, 80)
                            } else {
                                ForEach(store.items.filter { $0.percentageLeft <= 20 }) { item in
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.red.opacity(0.1))
                                                .frame(width: 44, height: 44)
                                            Text(item.displayEmoji)
                                                .font(.system(size: 22))
                                        }
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.name)
                                                .font(.system(size: 15, weight: .semibold))
                                            Text("\(Int(item.percentageLeft))% left")
                                                .font(.system(size: 13))
                                                .foregroundColor(.red)
                                        }
                                        Spacer()
                                        Text(item.statusText)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.red)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(Color.red.opacity(0.1))
                                            .cornerRadius(10)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.top)
                    }
                }
                .navigationTitle("Low Stock Items")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { showLowStock = false }) {
                            Image(systemName: "arrow.left").foregroundColor(.black)
                        }
                    }
                }
            }
        }
        
        // Categories Sheet
        .sheet(isPresented: $showCategories) {
            NavigationView {
                ZStack {
                    Color(red: 0.95, green: 0.98, blue: 0.95).ignoresSafeArea()
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(categoriesWithCount, id: \.0) { category, count in
                                HStack(spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.purple.opacity(0.15))
                                            .frame(width: 44, height: 44)
                                        Image(systemName: "tag.fill")
                                            .foregroundColor(.purple)
                                            .font(.system(size: 18))
                                    }
                                    Text(category)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.black)
                                    Spacer()
                                    Text("\(count) items")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.purple)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.purple.opacity(0.1))
                                        .cornerRadius(10)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(16)
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top)
                        .padding(.bottom, 20)
                    }
                }
                .navigationTitle("Categories (\(totalCategories))")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { showCategories = false }) {
                            Image(systemName: "arrow.left").foregroundColor(.black)
                        }
                    }
                }
            }
        }
        
        // Spending History Sheet
        .sheet(isPresented: $showSpending) {
            NavigationView {
                ZStack {
                    Color(red: 0.95, green: 0.98, blue: 0.95).ignoresSafeArea()
                    ScrollView {
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(filterSpendingByDate ? "Filtered Spent" : "Total Spent")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                    Text("$\(String(format: "%.2f", filterSpendingByDate ? getMonthlySpending().reduce(0) { $0 + $1.1 } : totalSpent))")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.green)
                                }
                                Spacer()
                                VStack(spacing: 4) {
                                    Button(action: { showSpendingDatePicker = true }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "calendar")
                                                .font(.system(size: 12))
                                            Text(filterSpendingByDate ? "Filtered" : "All Dates")
                                                .font(.system(size: 12, weight: .medium))
                                        }
                                        .foregroundColor(filterSpendingByDate ? .white : .green)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(filterSpendingByDate ? Color.green : Color.green.opacity(0.1))
                                        .cornerRadius(20)
                                    }
                                    if filterSpendingByDate {
                                        Button(action: { filterSpendingByDate = false }) {
                                            Text("Clear")
                                                .font(.system(size: 11))
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .padding(.horizontal)
                            
                            if getMonthlySpending().isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "calendar.badge.exclamationmark")
                                        .font(.system(size: 50))
                                        .foregroundColor(.orange.opacity(0.5))
                                    Text("No spending on this date")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.gray)
                                }
                                .padding(.top, 40)
                            } else {
                                ForEach(getMonthlySpending(), id: \.0) { month, amount, logs in
                                    VStack(alignment: .leading, spacing: 0) {
                                        HStack {
                                            Text(month)
                                                .font(.system(size: 15, weight: .bold))
                                            Spacer()
                                            Text("$\(String(format: "%.2f", amount))")
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundColor(.green)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(Color.green.opacity(0.08))
                                        .cornerRadius(12)
                                        
                                        VStack(spacing: 0) {
                                            ForEach(logs) { log in
                                                HStack(spacing: 12) {
                                                    Text(log.emoji)
                                                        .font(.system(size: 20))
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(log.itemName)
                                                            .font(.system(size: 14, weight: .semibold))
                                                        Text(log.date, style: .date)
                                                            .font(.system(size: 12))
                                                            .foregroundColor(.gray)
                                                    }
                                                    Spacer()
                                                    Text("$\(log.price, specifier: "%.2f")")
                                                        .font(.system(size: 14, weight: .bold))
                                                }
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 10)
                                                if log.id != logs.last?.id {
                                                    Divider().padding(.leading, 44)
                                                }
                                            }
                                        }
                                        .background(Color.white)
                                        .cornerRadius(12)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.top)
                        .padding(.bottom, 20)
                    }
                }
                .navigationTitle("Spending History")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { showSpending = false }) {
                            Image(systemName: "arrow.left").foregroundColor(.black)
                        }
                    }
                }
                .sheet(isPresented: $showSpendingDatePicker) {
                    NavigationView {
                        ZStack {
                            Color(red: 0.95, green: 0.98, blue: 0.95).ignoresSafeArea()
                            VStack(spacing: 24) {
                                DatePicker("Select Date", selection: $spendingDate, displayedComponents: .date)
                                    .datePickerStyle(.graphical)
                                    .tint(.green)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .padding()
                                
                                Button(action: {
                                    filterSpendingByDate = true
                                    showSpendingDatePicker = false
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
                                    filterSpendingByDate = false
                                    showSpendingDatePicker = false
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
                                Button(action: { showSpendingDatePicker = false }) {
                                    Image(systemName: "arrow.left").foregroundColor(.black)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // About Sheet
        .sheet(isPresented: $showAbout) {
            NavigationView {
                ZStack {
                    Color(red: 0.95, green: 0.98, blue: 0.95).ignoresSafeArea()
                    VStack(spacing: 24) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.green)
                                .frame(width: 100, height: 100)
                            Image(systemName: "cabinet.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 40)
                        
                        Text("HomShelf")
                            .font(.system(size: 28, weight: .bold))
                        
                        Text("Your Smart Pantry")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 12) {
                            AboutRow(title: "Version", value: "1.0.0")
                            Divider()
                            AboutRow(title: "Developer", value: "maniraj-48")
                            Divider()
                            AboutRow(title: "Built with", value: "SwiftUI")
                            Divider()
                            AboutRow(title: "AI Feature", value: "Gemini AI")
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                }
                .navigationTitle("About")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { showAbout = false }) {
                            Image(systemName: "arrow.left").foregroundColor(.black)
                        }
                    }
                }
            }
        }
    }
}

// Stat Box Component
struct StatBox: View {
    var value: String
    var label: String
    var color: Color
    var icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 16))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(12)
        .background(Color(red: 0.95, green: 0.98, blue: 0.95))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// Settings Row Component
struct SettingsRow: View {
    var icon: String
    var title: String
    var color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 14))
            }
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.black)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14))
        }
        .padding()
    }
}

// About Row Component
struct AboutRow: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.black)
        }
    }
}
