import SwiftUI

struct ItemDetailView: View {
    var item: GroceryItem
    @ObservedObject var store: ItemStore
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteAlert = false
    @State private var showEditItem = false
    @State private var showRefillSheet = false
    @State private var showHistorySheet = false
    @State private var newPrice = ""
    @State private var newQuantity = ""
    @State private var newDate = Date()
    
    // Color based on percentage
    var progressColor: Color {
        if item.percentageLeft > 50 { return .green }
        else if item.percentageLeft > 20 { return .orange }
        else { return .red }
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
                        
                        // Edit Button
                        Button(action: {
                            showEditItem = true
                        }) {
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
                        
                        // History Button
                        Button(action: {
                            showHistorySheet = true
                        }) {
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
                        
                        // Refill Button
                        Button(action: {
                            showRefillSheet = true
                        }) {
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
                        Button(action: {}) {
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
                        
                        // Delete Button
                        Button(action: {
                            showDeleteAlert = true
                        }) {
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
        
        // History Sheet
        .sheet(isPresented: $showHistorySheet) {
            NavigationView {
                ZStack {
                    Color(red: 0.95, green: 0.98, blue: 0.95)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        
                        if item.purchaseHistory.isEmpty {
                            // No history yet
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
                                            
                                            // Date circle
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
                                                    .foregroundColor(.black)
                                                Text(record.quantity)
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            Spacer()
                                            
                                            // Price
                                            Text("$\(record.price, specifier: "%.2f")")
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(.black)
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
                            Image(systemName: "arrow.left")
                                .foregroundColor(.black)
                        }
                    }
                }
            }
        }
        
        // Refill Sheet
        .sheet(isPresented: $showRefillSheet) {
            NavigationView {
                ZStack {
                    Color(red: 0.95, green: 0.98, blue: 0.95)
                        .ignoresSafeArea()
                    
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
                            
                            // New Price
                            VStack(alignment: .leading, spacing: 8) {
                                Text("New Price")
                                    .font(.system(size: 16, weight: .semibold))
                                HStack {
                                    Text("$")
                                        .foregroundColor(.gray)
                                    TextField("Enter new price", text: $newPrice)
                                        .keyboardType(.decimalPad)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(30)
                            }
                            
                            // New Quantity
                            VStack(alignment: .leading, spacing: 8) {
                                Text("New Quantity")
                                    .font(.system(size: 16, weight: .semibold))
                                TextField("e.g. 1 lb, 2L...", text: $newQuantity)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(30)
                            }
                            
                            // Purchase Date
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Purchase Date")
                                    .font(.system(size: 16, weight: .semibold))
                                DatePicker(
                                    "",
                                    selection: $newDate,
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.compact)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(30)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        // Refill Button
                        Button(action: {
                            let price = Double(newPrice) ?? item.pricePaid
                            let quantity = newQuantity.isEmpty ? item.quantity : newQuantity
                            store.refillItem(
                                item,
                                newPrice: price,
                                newQuantity: quantity,
                                newDate: newDate
                            )
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
                        
                        Button(action: {
                            showRefillSheet = false
                        }) {
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
                            Image(systemName: "arrow.left")
                                .foregroundColor(.black)
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


