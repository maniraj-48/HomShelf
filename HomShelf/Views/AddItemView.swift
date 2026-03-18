import SwiftUI

struct AddItemView: View {
    @ObservedObject var store: ItemStore
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var category = "Dairy"
    @State private var quantity = ""
    @State private var pricePaid = ""
    @State private var totalDays = 7
    @State private var notifyWhenLow = true
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showPhotoOptions = false
    @State private var customEmoji = ""
    @State private var customCategory = ""
    @State private var showCustomCategory = false
    
    let categories = ["Dairy", "Produce", "Grains", "Meat", "Snacks", "Other", "+ Add Custom"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.95, green: 0.98, blue: 0.95)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Photo Area
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.15))
                                .frame(height: 180)
                            
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 180)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            } else {
                                VStack(spacing: 10) {
                                    Image(systemName: "camera.badge.plus")
                                        .font(.system(size: 36))
                                        .foregroundColor(.gray)
                                    Text("Tap to add photo")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .onTapGesture {
                            showPhotoOptions = true
                        }
                        
                        // Change Photo Button
                        Button(action: {
                            showPhotoOptions = true
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Change Photo")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.green)
                            .cornerRadius(30)
                        }
                        
                        // Form Fields
                        VStack(alignment: .leading, spacing: 16) {
                            
                            // Item Name
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Item Name")
                                    .font(.system(size: 16, weight: .semibold))
                                TextField("e.g. Organic Milk", text: $name)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(30)
                            }
                            
                            // Emoji Option
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Emoji (Optional)")
                                    .font(.system(size: 16, weight: .semibold))
                                HStack {
                                    TextField("e.g. 🥚 or leave empty", text: $customEmoji)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(30)
                                    
                                    ZStack {
                                        Circle()
                                            .fill(Color.green.opacity(0.1))
                                            .frame(width: 50, height: 50)
                                        Text(customEmoji.isEmpty ?
                                             String(name.prefix(1)).uppercased() :
                                             customEmoji)
                                            .font(.system(size: 22, weight: .bold))
                                    }
                                }
                                Text("Leave empty to show first letter of item name")
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                            }
                            
                            // Category — Full width
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Category")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                if showCustomCategory {
                                    HStack {
                                        TextField("Type category...", text: $customCategory)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(30)
                                        Button(action: {
                                            showCustomCategory = false
                                            category = "Dairy"
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                } else {
                                    Picker("Category", selection: $category) {
                                        ForEach(categories, id: \.self) { cat in
                                            Text(cat).tag(cat)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(30)
                                    .onChange(of: category) {
                                        if category == "+ Add Custom" {
                                            showCustomCategory = true
                                            customCategory = ""
                                        }
                                    }
                                }
                            }
                            
                            // Quantity — Full width
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Quantity")
                                    .font(.system(size: 16, weight: .semibold))
                                TextField("e.g. 1 lb, 2L, 12 pack...", text: $quantity)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(30)
                            }
                            
                            // Price and Duration
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Price Paid")
                                        .font(.system(size: 16, weight: .semibold))
                                    HStack {
                                        Text("$")
                                            .foregroundColor(.gray)
                                        TextField("0.00", text: $pricePaid)
                                            .keyboardType(.decimalPad)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(30)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Duration (Days)")
                                        .font(.system(size: 16, weight: .semibold))
                                    HStack {
                                        Button(action: {
                                            if totalDays > 1 { totalDays -= 1 }
                                        }) {
                                            Image(systemName: "minus")
                                                .foregroundColor(.green)
                                        }
                                        Spacer()
                                        Text("\(totalDays)")
                                            .font(.system(size: 16, weight: .bold))
                                        Spacer()
                                        Button(action: {
                                            totalDays += 1
                                        }) {
                                            Image(systemName: "plus")
                                                .foregroundColor(.green)
                                        }
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(30)
                                }
                            }
                            
                            // Notify Toggle
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Notify me when low")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Get an alert when stock hits 20%")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Toggle("", isOn: $notifyWhenLow)
                                    .tint(.green)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal)
                        
                        // Save Button
                        Button(action: saveItem) {
                            Text("Save Item")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(30)
                                .padding(.horizontal)
                        }
                        
                        // Cancel Button
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Cancel")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.green)
                        }
                        
                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Add New Item")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .confirmationDialog("Add Photo", isPresented: $showPhotoOptions) {
                Button("Take Photo") { showCamera = true }
                Button("Choose from Gallery") { showImagePicker = true }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(image: $selectedImage, sourceType: .camera)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
    
    func saveItem() {
        let finalCategory = showCustomCategory ? customCategory : category
        
        var newItem = GroceryItem(
            name: name,
            category: finalCategory,
            quantity: quantity,
            pricePaid: Double(pricePaid) ?? 0.0,
            totalDays: totalDays,
            dateAdded: Date(),
            imageName: "",
            notifyWhenLow: notifyWhenLow
        )
        if !customEmoji.isEmpty {
            newItem.customEmoji = customEmoji
        }
        if let image = selectedImage {
            newItem.imageFileName = ImageStorage.saveImage(image)
        }
        store.addItem(newItem)
        dismiss()
    }
}

#Preview {
    AddItemView(store: ItemStore())
}
