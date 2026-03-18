import SwiftUI

struct MainTabView: View {
    @StateObject var store = ItemStore()
    
    var body: some View {
        TabView {
            // Tab 1 - Wardboard
            WardboardView(store: store)
                .tabItem {
                    VStack {
                        Image(systemName: "cabinet.fill")
                        Text("Wardboard")
                    }
                }
            
            // Tab 2 - List
            ListView()
                .environmentObject(store)
                .tabItem {
                    VStack {
                        Image(systemName: "cart.fill")
                        Text("List")
                    }
                }
            
            // Tab 3 - Profile
            ProfileView()
                .tabItem {
                    VStack {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
                }
        }
        .accentColor(.green)
    }
}

