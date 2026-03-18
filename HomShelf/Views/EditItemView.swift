import SwiftUI

struct EditItemView: View {
    @EnvironmentObject var store: ItemStore
    var item: GroceryItem
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
                                .frame(height: 200)
                            
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            } else if let fileName = item.imageFileName,
                                      let uiImage = ImageStorage.loadImage(fileName: fileName) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            } else {
                                VStack(spacing: 8) {
                                    Image(systemName: "camera.badge.plus")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray.opacity(0.5))
                                    Text("Tap to add photo")
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
                            
                            // Category and Quantity
                            HStack(spacing: 12) {
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
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Quantity")
                                        .font(.system(size: 16, weight: .semibold))
                                    TextField("1 lb, 2L...", text: $quantity)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(30)
                                }
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
                            Text("Save Changes")
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
            .navigationTitle("Edit Item")
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
            .onAppear {
                name = item.name
                category = item.category
                quantity = item.quantity
                pricePaid = String(item.pricePaid)
                totalDays = item.totalDays
                notifyWhenLow = item.notifyWhenLow
                customEmoji = item.customEmoji ?? ""
                if !categories.contains(item.category) {
                    showCustomCategory = true
                    customCategory = item.category
                }
            }
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
        }
    }
    
    func saveItem() {
        let finalCategory = showCustomCategory ? customCategory : category
        
        var updatedItem = item
        updatedItem.name = name
        updatedItem.category = finalCategory
        updatedItem.quantity = quantity
        updatedItem.pricePaid = Double(pricePaid) ?? item.pricePaid
        updatedItem.totalDays = totalDays
        updatedItem.notifyWhenLow = notifyWhenLow
        updatedItem.customEmoji = customEmoji.isEmpty ? nil : customEmoji
        
        if let image = selectedImage {
            if let oldFileName = item.imageFileName {
                ImageStorage.deleteImage(fileName: oldFileName)
            }
            updatedItem.imageFileName = ImageStorage.saveImage(image)
        }
        
        store.updateItem(updatedItem)
        dismiss()
    }
}
