# HomShelf — Your Smart Pantry

🔍 Problem

Many people forget to buy necessary grocery items even when they prepare a list before going to the store. This happens because people don't know exactly what items are left at home or how much remains. Someone may think there is enough rice, milk, or eggs at home, but when they return from shopping they realize the item is finished leading to inconvenience, extra trips to the store, and poor household inventory management.

💡 Solution

**HomShelf** is a smart iOS pantry management app that solves this problem by tracking household grocery items visually. After purchasing groceries, users enter item details such as quantity, price, and estimated duration. The app automatically decreases the stock percentage daily and alerts users when items are running low ensuring they never forget to restock essential items again.

### HomShelf also helps you:

- 💰 **Track every purchase price** — Record the price you paid each time you buy an item so you always know what you spent
- 📊 **Compare prices over time** — See if the price of rice, milk or any item went up or down since your last purchase
- 🤖 **AI Price Check** — Tap "See Price Today" on any item and Gemini AI will analyze the current market price online so you can decide whether to buy now or wait
- 📈 **Monitor total grocery spending** — See exactly how much you have invested in groceries month by month with a full spending history breakdown
- 🗂️ **Track by category** — View spending and stock levels across Dairy, Produce, Grains, Meat and custom categories
- 📋 **Shopping Journal** — Every purchase, refill and deletion is logged with date and price so you have a complete history of your grocery activity
- 🔔 **Smart Alerts** — Get notified automatically when any item drops below 20% so you never run out of essentials

With HomShelf, users have complete visibility into their household supplies, spending habits, and grocery price trends — all in one place.


## ✨ Features

- 🏠 **Digital Wardboard** — Visual grid showing all pantry items with stock levels
- 📊 **Auto Stock Tracking** — Items automatically decrease % based on purchase date and duration
- 🔔 **Low Stock Alerts** — Push notifications when items drop below 20%
- 💰 **Price Tracking** — Record purchase prices and track price history
- 🤖 **AI Price Check** — Gemini AI analyzes current market prices (Coming Soon)
- 📋 **Shopping Journal** — Track all purchases by date with Added/Refilled/Deleted history
- 🗂️ **Categories** — Organize items by Dairy, Produce, Grains, Meat, Snacks or custom
- 📸 **Item Photos** — Add photos from camera or gallery
- ✏️ **Custom Emoji** — Set custom emojis for each item
- 🔄 **Refill System** — Refill items with new price, quantity and date
- 📈 **Spending History** — Monthly breakdown of grocery spending
- 👤 **Profile** — Personalized profile with pantry stats

---

## 🛠️ Tech Stack

| Technology | Usage |
|---|---|
| **Swift** | Primary programming language |
| **SwiftUI** | UI framework |
| **UserDefaults** | Local data persistence |
| **FileManager** | Photo storage |
| **UserNotifications** | Push notifications |
| **Gemini AI** | AI price check feature |
| **REST APIs** | Real-time price data |

---

## 📁 Project Structure
```
HomShelf/
├── Models/
│   ├── GroceryItem.swift       # Data model
│   ├── ItemStore.swift         # Data manager
│   ├── ImageStorage.swift      # Photo storage
│   └── NotificationManager.swift # Push notifications
├── Views/
│   ├── SplashView.swift        # Welcome screen
│   ├── MainTabView.swift       # Tab navigation
│   ├── WardboardView.swift     # Home screen
│   ├── AddItemView.swift       # Add new item
│   ├── EditItemView.swift      # Edit item
│   ├── ItemDetailView.swift    # Item details
│   ├── ListView.swift          # Shopping journal
│   └── ProfileView.swift       # Profile & stats
└── Components/
    ├── ItemCardView.swift      # Item card component
    └── ImagePicker.swift       # Camera/gallery picker
```

---

## 🚀 Getting Started

### Requirements
- Mac with macOS 13+
- Xcode 15+
- iOS 17+ device or simulator

### Installation

**1 — Clone the repository:**
```bash
git clone https://github.com/maniraj-48/HomShelf.git
```

**2 — Open in Xcode:**
```bash
cd HomShelf
open HomShelf.xcodeproj
```

**3 — Run the app:**
- Select your simulator or device
- Press ▶️ Play button

---

## 📊 How It Works
```
User adds item → Sets duration (days)
      ↓
App tracks daily usage automatically
      ↓
Progress bar decreases each day
      ↓
Below 20% → Push notification sent
      ↓
User refills → History saved
      ↓
AI checks current market price
```

---

## 🗓️ Development Plan

| Day | Feature | Status |
|---|---|---|
| Day 1 | Project Setup + Wardboard | ✅ Done |
| Day 2 | Navigation + Detail Screen | ✅ Done |
| Day 3 | Save, Delete, Edit, Photo | ✅ Done |
| Day 4 | UI Polish | ✅ Done |
| Day 5 | UI Polish | ✅ Done |
| Day 6 | Profile Screen | ✅ Done |
| Day 7 | Push Notifications | ✅ Done |
| Day 8 | AI Price Check | 🔜 In Progress |
| Day 9 | Bug Fixes + Testing | 🔜 |
| Day 10 | Final Polish + App Store | 🔜 |

---

## 👨‍💻 Developer

**Maniraj** — [@maniraj-48](https://github.com/maniraj-48)

---

## 📄 License

This project is for personal and portfolio use.

---

⭐ If you like this project, give it a star on GitHub!
