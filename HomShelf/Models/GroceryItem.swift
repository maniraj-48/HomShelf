import Foundation

// Purchase history record
// 💡 Every time user refills → one record saved here
struct PurchaseRecord: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var price: Double
    var quantity: String
}

struct GroceryItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var category: String
    var quantity: String
    var pricePaid: Double
    var totalDays: Int
    var dateAdded: Date
    var imageName: String
    var notifyWhenLow: Bool
    var imageFileName: String?
    var customEmoji: String?
    var purchaseHistory: [PurchaseRecord] = []
    
    // Shows emoji if user set one
    // OR first letter of item name by default
    var displayEmoji: String {
        if let emoji = customEmoji, !emoji.isEmpty {
            return emoji
        }
        return String(self.name.prefix(1)).uppercased()
    }
    
    // This calculates % automatically based on days passed
    var percentageLeft: Double {
        let daysPassed = Calendar.current.dateComponents(
            [.day],
            from: dateAdded,
            to: Date()
        ).day ?? 0
        let remaining = Double(totalDays - daysPassed) / Double(totalDays) * 100
        return max(0, min(100, remaining))
    }
    
    // This gives status text based on percentage
    var statusText: String {
        if percentageLeft > 50 { return "Fresh" }
        else if percentageLeft > 20 { return "Running Low" }
        else if percentageLeft > 0 { return "Restock!" }
        else { return "Finished" }
    }
}
