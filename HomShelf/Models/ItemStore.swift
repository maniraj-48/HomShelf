import Foundation
import Combine

// 💡 Activity Log Entry
// Saved separately from items
// So even if item deleted → history stays ✅
struct ActivityLog: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var itemName: String
    var action: String // "Added" or "Refilled"
    var price: Double
    var quantity: String
    var emoji: String
    var category: String
}

class ItemStore: ObservableObject {
    @Published var items: [GroceryItem] = [] {
        didSet {
            saveItems()
        }
    }
    
    // 💡 Separate activity log
    // Never deleted even when item is deleted
    @Published var activityLog: [ActivityLog] = [] {
        didSet {
            saveActivityLog()
        }
    }
    
    init() {
        loadItems()
        loadActivityLog()
        
        if items.isEmpty {
            let sampleItems = [
                GroceryItem(
                    name: "Whole Milk",
                    category: "Dairy",
                    quantity: "1 Gallon",
                    pricePaid: 4.50,
                    totalDays: 10,
                    dateAdded: Calendar.current.date(
                        byAdding: .day,
                        value: -2,
                        to: Date()
                    )!,
                    imageName: "",
                    notifyWhenLow: true
                ),
                GroceryItem(
                    name: "Basmati Rice",
                    category: "Grains",
                    quantity: "1 lb",
                    pricePaid: 12.99,
                    totalDays: 30,
                    dateAdded: Calendar.current.date(
                        byAdding: .day,
                        value: -20,
                        to: Date()
                    )!,
                    imageName: "",
                    notifyWhenLow: true
                ),
                GroceryItem(
                    name: "Organic Eggs",
                    category: "Dairy",
                    quantity: "12 pack",
                    pricePaid: 5.25,
                    totalDays: 14,
                    dateAdded: Calendar.current.date(
                        byAdding: .day,
                        value: -13,
                        to: Date()
                    )!,
                    imageName: "",
                    notifyWhenLow: true
                ),
                GroceryItem(
                    name: "Fuji Apples",
                    category: "Produce",
                    quantity: "4 pack",
                    pricePaid: 3.80,
                    totalDays: 10,
                    dateAdded: Calendar.current.date(
                        byAdding: .day,
                        value: -1,
                        to: Date()
                    )!,
                    imageName: "",
                    notifyWhenLow: false
                )
            ]
            
            // Add each sample item through addItem
            // so they get saved to activity log too ✅
            for item in sampleItems {
                addItem(item)
            }
        }
    }
    
    // Save items to UserDefaults
    func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "homshelf_items")
        }
    }
    
    // Load items from UserDefaults
    func loadItems() {
        if let savedItems = UserDefaults.standard.data(forKey: "homshelf_items") {
            if let decoded = try? JSONDecoder().decode([GroceryItem].self, from: savedItems) {
                items = decoded
            }
        }
    }
    
    // Save activity log to UserDefaults
    func saveActivityLog() {
        if let encoded = try? JSONEncoder().encode(activityLog) {
            UserDefaults.standard.set(encoded, forKey: "homshelf_activity_log")
        }
    }
    
    // Load activity log from UserDefaults
    func loadActivityLog() {
        if let savedLog = UserDefaults.standard.data(forKey: "homshelf_activity_log") {
            if let decoded = try? JSONDecoder().decode([ActivityLog].self, from: savedLog) {
                activityLog = decoded
            }
        }
    }
    
    // Add new item
    // 💡 Saves to activity log as "Added"
    func addItem(_ item: GroceryItem) {
        var newItem = item
        let firstRecord = PurchaseRecord(
            date: item.dateAdded,
            price: item.pricePaid,
            quantity: item.quantity
        )
        newItem.purchaseHistory = [firstRecord]
        items.append(newItem)
        
        // Save to activity log
        let log = ActivityLog(
            date: item.dateAdded,
            itemName: item.name,
            action: "Added",
            price: item.pricePaid,
            quantity: item.quantity,
            emoji: item.displayEmoji,
            category: item.category
        )
        activityLog.append(log)
        
        // Schedule daily check
        NotificationManager.shared.scheduleDailyCheck(for: items)
    }
    
    // Delete item
    // 💡 Saves "Deleted" to activity log ✅
    func deleteItem(_ item: GroceryItem) {
        if let fileName = item.imageFileName {
            ImageStorage.deleteImage(fileName: fileName)
        }
        items.removeAll { $0.id == item.id }
        
        // Save deletion to activity log
        let log = ActivityLog(
            date: Date(),
            itemName: item.name,
            action: "Deleted",
            price: item.pricePaid,
            quantity: item.quantity,
            emoji: item.displayEmoji,
            category: item.category
        )
        activityLog.append(log)
    }
    
    // Update item
    func updateItem(_ item: GroceryItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
            
            // Check if item is low and send notification
            if item.percentageLeft <= 20 && item.notifyWhenLow {
                NotificationManager.shared.sendLowStockNotification(for: item)
            }
        }
    }
    
    // Refill item
    // 💡 Saves to activity log as "Refilled"
    func refillItem(_ item: GroceryItem, newPrice: Double, newQuantity: String, newDate: Date) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            var updatedItem = items[index]
            
            let record = PurchaseRecord(
                date: newDate,
                price: newPrice,
                quantity: newQuantity
            )
            updatedItem.purchaseHistory.append(record)
            updatedItem.dateAdded = newDate
            updatedItem.pricePaid = newPrice
            updatedItem.quantity = newQuantity
            
            items[index] = updatedItem
            
            // Save to activity log
            let log = ActivityLog(
                date: newDate,
                itemName: item.name,
                action: "Refilled",
                price: newPrice,
                quantity: newQuantity,
                emoji: item.displayEmoji,
                category: item.category
            )
            activityLog.append(log)
        }
    }
}
