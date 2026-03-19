import Foundation
import UserNotifications

class NotificationManager {
    
    static let shared = NotificationManager()
    
    // Request permission from user
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            if granted {
                print("Notification permission granted ✅")
            } else {
                print("Notification permission denied ❌")
            }
        }
    }
    
    // Send low stock notification
    func sendLowStockNotification(for item: GroceryItem) {
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Low Stock Alert!"
        content.body = "\(item.name) is running low — only \(Int(item.percentageLeft))% left. Time to restock!"
        content.sound = .default
        
        // Trigger immediately
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "low_stock_\(item.id)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error)")
            }
        }
    }
    
    // Schedule daily check notification
    func scheduleDailyCheck(for items: [GroceryItem]) {
        // Remove all pending notifications first
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Get low stock items
        let lowStockItems = items.filter {
            $0.percentageLeft <= 20 && $0.notifyWhenLow
        }
        
        if lowStockItems.isEmpty { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🛒 HomShelf Reminder"
        content.body = "\(lowStockItems.count) item(s) are running low: \(lowStockItems.map { $0.name }.joined(separator: ", "))"
        content.sound = .default
        
        // Schedule for 9 AM daily
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: "daily_check",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
