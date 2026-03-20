import SwiftUI

struct ItemDetailView: View {
    var item: GroceryItem
    @ObservedObject var store: ItemStore
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteAlert = false
    @State private var showEditItem = false
    @State private var showRefillSheet = false
    @State private var showHistorySheet = false
    @State private var showPriceCheck = false
    @State private var newPrice = ""
    @State private var newQuantity = ""
    @State private var newDate = Date()
    @State private var priceResult: PriceResult? = nil
    @State private var isLoadingPrice = false
    @State private var priceError = false
    
    var progressColor: Color {
        if item.percentageLeft > 50 { return .green }
        else if item.percentageLeft > 20 { return .orange }
        else { return .red }
    }
    
    func storeEmoji(_ storeName: String) -> String {
        let name = storeName.lowercased()
        if name.contains("walmart") { return "🛒" }
        if name.contains("amazon") { return "📦" }
        if name.contains("costco") { return "🏪" }
        if name.contains("target") { return "🎯" }
        if name.contains("kroger") { return "🏬" }
        if name.contains("whole") { return "🌿" }
        if name.contains("trader") { return "🛍️" }
        if name.contains("aldi") { return "🏷️" }
        return "🏪"
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.98, blue: 0.95)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    
                    // Item Image Area
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 220)
                        
                        if let fileName = item.imageFileName,
                           let uiImage = ImageStorage.loadImage(fileName: fileName) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 220)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        } else {
                            VStack(spacing: 8) {
                                Text(item.displayEmoji)
                                    .font(.system(size: 70))
                                Text(item.name)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Item Name & Category
                    VStack(spacing: 8) {
                        Text(item.name)
                            .font(.system(size: 26, weight: .bold))
                        Text(item.category)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(20)
                    }
                    
                    // Stock Level Card
                    VStack(spacing: 12) {
                        HStack {
                            Text("Stock Level")
                                .font(.system(size: 16, weight: .semibold))
                            Spacer()
                            Text("\(Int(item.percentageLeft))% left")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(progressColor)
                        }
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 12)
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(progressColor)
                                    .frame(
                                        width: geometry.size.width * CGFloat(item.percentageLeft / 100),
                                        height: 12
                                    )
                            }
                        }
                        .frame(height: 12)
                        HStack {
                            Text(item.statusText)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(progressColor)
                            Spacer()
                            Text("\(item.totalDays) days total")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Purchase Details Card
                    VStack(spacing: 16) {
                        Text("Purchase Details")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            VStack(spacing: 4) {
                                Text("Price Paid")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                Text("$\(item.pricePaid, specifier: "%.2f")")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity)
                            Divider().frame(height: 40)
                            VStack(spacing: 4) {
                                Text("Quantity")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                Text(item.quantity)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity)
                            Divider().frame(height: 40)
                            VStack(spacing: 4) {
                                Text("Added")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                Text(item.dateAdded, style: .date)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Edit & History Box
                    HStack(spacing: 12) {
                        Button(action: { showEditItem = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 20))
                                Text("Edit")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(16)
                        }
                        Button(action: { showHistorySheet = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 20))
                                Text("History")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(16)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: { showRefillSheet = true }) {
                            HStack {
                                Image(systemName: "arrow.clockwise.circle.fill")
                                    .font(.system(size: 20))
                                Text("Refill Item")
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(30)
                        }
                        
                        // AI Price Check Button
                        Button(action: {
                            priceResult = nil
                            priceError = false
                            isLoadingPrice = true
                            showPriceCheck = true
                            GeminiService.shared.checkPrice(
                                itemName: item.name,
                                quantity: item.quantity
                            ) { result in
                                DispatchQueue.main.async {
                                    isLoadingPrice = false
                                    if let result = result {
                                        priceResult = result
                                    } else {
                                        priceError = true
                                    }
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 20))
                                Text("See Price Today")
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(30)
                        }
                        
                        Button(action: { showDeleteAlert = true }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 20))
                                Text("Delete Item")
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal)
                    Spacer().frame(height: 20)
                }
                .padding(.top)
            }
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.black)
                }
            }
        }
        
        // AI Price Check Sheet
        .sheet(isPresented: $showPriceCheck) {
            PriceCheckView(
                item: item,
                isLoading: $isLoadingPrice,
                priceResult: $priceResult,
                priceError: $priceError,
                storeEmojiFunc: storeEmoji
            )
        }
        
        // History Sheet
        .sheet(isPresented: $showHistorySheet) {
            NavigationView {
                ZStack {
                    Color(red: 0.95, green: 0.98, blue: 0.95).ignoresSafeArea()
                    VStack(spacing: 0) {
                        if item.purchaseHistory.isEmpty {
                            VStack(spacing: 16) {
                                Spacer()
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.purple.opacity(0.4))
                                Text("No History Yet")
                                    .font(.system(size: 22, weight: .bold))
                                Text("History will appear here\nafter your first refill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                Spacer()
                            }
                        } else {
                            ScrollView {
                                VStack(spacing: 12) {
                                    ForEach(item.purchaseHistory.reversed()) { record in
                                        HStack(spacing: 16) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.purple.opacity(0.15))
                                                    .frame(width: 50, height: 50)
                                                Image(systemName: "calendar")
                                                    .foregroundColor(.purple)
                                            }
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(record.date, style: .date)
                                                    .font(.system(size: 14, weight: .semibold))
                                                Text(record.quantity)
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.gray)
                                            }
                                            Spacer()
                                            Text("$\(record.price, specifier: "%.2f")")
                                                .font(.system(size: 18, weight: .bold))
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
                    }
                }
                .navigationTitle("Purchase History")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { showHistorySheet = false }) {
                            Image(systemName: "arrow.left").foregroundColor(.black)
                        }
                    }
                }
            }
        }
        
        // Refill Sheet
        .sheet(isPresented: $showRefillSheet) {
            NavigationView {
                ZStack {
                    Color(red: 0.95, green: 0.98, blue: 0.95).ignoresSafeArea()
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.orange.opacity(0.15))
                                    .frame(width: 80, height: 80)
                                Image(systemName: "arrow.clockwise.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.orange)
                            }
                            Text("Refill \(item.name)")
                                .font(.system(size: 22, weight: .bold))
                            Text("Update price, quantity and date")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("New Price")
                                    .font(.system(size: 16, weight: .semibold))
                                HStack {
                                    Text("$").foregroundColor(.gray)
                                    TextField("Enter new price", text: $newPrice)
                                        .keyboardType(.decimalPad)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(30)
                            }
                            VStack(alignment: .leading, spacing: 8) {
                                Text("New Quantity")
                                    .font(.system(size: 16, weight: .semibold))
                                TextField("e.g. 1 lb, 2L...", text: $newQuantity)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(30)
                            }
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Purchase Date")
                                    .font(.system(size: 16, weight: .semibold))
                                DatePicker("", selection: $newDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(30)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        Button(action: {
                            let price = Double(newPrice) ?? item.pricePaid
                            let quantity = newQuantity.isEmpty ? item.quantity : newQuantity
                            store.refillItem(item, newPrice: price, newQuantity: quantity, newDate: newDate)
                            showRefillSheet = false
                        }) {
                            Text("Refill Now ✅")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(30)
                                .padding(.horizontal)
                        }
                        Button(action: { showRefillSheet = false }) {
                            Text("Cancel")
                                .font(.system(size: 16))
                                .foregroundColor(.orange)
                        }
                        Spacer().frame(height: 20)
                    }
                }
                .navigationTitle("Refill Item")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { showRefillSheet = false }) {
                            Image(systemName: "arrow.left").foregroundColor(.black)
                        }
                    }
                }
                .onAppear {
                    newPrice = String(item.pricePaid)
                    newQuantity = item.quantity
                    newDate = Date()
                }
            }
        }
        
        // Edit Sheet
        .sheet(isPresented: $showEditItem) {
            EditItemView(item: item)
                .environmentObject(store)
        }
        
        // Delete Alert
        .alert("Delete Item", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                store.deleteItem(item)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \(item.name)?")
        }
    }
}

// Separate PriceCheckView to fix loading state issue
struct PriceCheckView: View {
    var item: GroceryItem
    @Binding var isLoading: Bool
    @Binding var priceResult: PriceResult?
    @Binding var priceError: Bool
    var storeEmojiFunc: (String) -> String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.95, green: 0.98, blue: 0.95)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        
                        // Header
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.green.opacity(0.15))
                                    .frame(width: 80, height: 80)
                                Image(systemName: "sparkles")
                                    .font(.system(size: 36))
                                    .foregroundColor(.green)
                            }
                            Text("AI Price Check")
                                .font(.system(size: 22, weight: .bold))
                            Text(item.name)
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)
                        
                        // Your Price Card
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Your Purchase Price")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                                Text("$\(item.pricePaid, specifier: "%.2f")")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.black)
                                Text(item.quantity)
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: "cart.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.green.opacity(0.3))
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        if isLoading {
                            // Loading State
                            VStack(spacing: 20) {
                                ZStack {
                                    Circle()
                                        .fill(Color.green.opacity(0.1))
                                        .frame(width: 100, height: 100)
                                    ProgressView()
                                        .scaleEffect(2)
                                        .tint(.green)
                                }
                                Text("Searching for best prices...")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.black)
                                Text("Gemini AI is checking\nWalmart, Amazon, Costco & more...")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(40)
                            
                        } else if priceError {
                            // Error State
                            VStack(spacing: 16) {
                                Image(systemName: "wifi.exclamationmark")
                                    .font(.system(size: 50))
                                    .foregroundColor(.orange.opacity(0.5))
                                Text("Could not fetch prices")
                                    .font(.system(size: 18, weight: .bold))
                                Text("Please check your internet connection")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                Button(action: {
                                    isLoading = true
                                    priceError = false
                                    priceResult = nil
                                    GeminiService.shared.checkPrice(
                                        itemName: item.name,
                                        quantity: item.quantity
                                    ) { result in
                                        DispatchQueue.main.async {
                                            isLoading = false
                                            if let result = result {
                                                priceResult = result
                                            } else {
                                                priceError = true
                                            }
                                        }
                                    }
                                }) {
                                    Text("Try Again")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 30)
                                        .padding(.vertical, 12)
                                        .background(Color.green)
                                        .cornerRadius(20)
                                }
                            }
                            .padding(40)
                            
                        } else if let result = priceResult {
                            
                            // Average Price Card
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Average Market Price")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray)
                                    Text(result.averagePrice)
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.green)
                                }
                                Spacer()
                                if let yourPrice = Double(item.pricePaid.description),
                                   let avgText = result.averagePrice.replacingOccurrences(of: "$", with: "").components(separatedBy: "-").first,
                                   let avgPrice = Double(avgText.trimmingCharacters(in: .whitespaces)) {
                                    VStack(spacing: 4) {
                                        if yourPrice > avgPrice {
                                            Text("You overpaid")
                                                .font(.system(size: 12))
                                                .foregroundColor(.red)
                                            Text("$\(String(format: "%.2f", yourPrice - avgPrice)) more")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.red)
                                        } else {
                                            Text("Good price!")
                                                .font(.system(size: 12))
                                                .foregroundColor(.green)
                                            Text("$\(String(format: "%.2f", avgPrice - yourPrice)) saved")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.green)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .padding(.horizontal)
                            
                            // Store Prices Card
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Store Prices")
                                    .font(.system(size: 16, weight: .bold))
                                ForEach(result.stores, id: \.name) { store in
                                    HStack {
                                        Text(storeEmojiFunc(store.name))
                                            .font(.system(size: 18))
                                        Text(store.name)
                                            .font(.system(size: 15))
                                            .foregroundColor(.black)
                                        Spacer()
                                        Text(store.price)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(store.name == result.cheapestStore ? .green : .black)
                                        if store.name == result.cheapestStore {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                                .font(.system(size: 14))
                                        }
                                    }
                                    if store.name != result.stores.last?.name {
                                        Divider()
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .padding(.horizontal)
                            
                            // Cheapest Store Card
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color.green.opacity(0.15))
                                        .frame(width: 50, height: 50)
                                    Image(systemName: "tag.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 20))
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Best Deal")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray)
                                    Text(result.cheapestStore)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.black)
                                    Text(result.cheapestPrice)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.green)
                                }
                                Spacer()
                                Text("Cheapest!")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.green)
                                    .cornerRadius(10)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .padding(.horizontal)
                            
                            // AI Recommendation
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(.green)
                                    Text("AI Recommendation")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                Text(result.recommendation)
                                    .font(.system(size: 14))
                                    .foregroundColor(.black.opacity(0.7))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding()
                            .background(Color.green.opacity(0.08))
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                        
                        Spacer().frame(height: 20)
                    }
                }
            }
            .navigationTitle("Price Check")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left").foregroundColor(.black)
                    }
                }
            }
        }
    }
}
