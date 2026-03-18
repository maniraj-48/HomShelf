import SwiftUI

struct ProfileView: View {
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.95, green: 0.98, blue: 0.95)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Profile")
                        .font(.system(size: 24, weight: .bold))
                    Spacer()
                    Image(systemName: "bell")
                        .font(.system(size: 20))
                }
                .padding()
                
                // Profile Card
                VStack(spacing: 16) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 100, height: 100)
                        Image(systemName: "person.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                    }
                    
                    Text("HomShelf User")
                        .font(.system(size: 20, weight: .bold))
                    
                    Text("Managing your pantry smartly")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(30)
                .background(Color.white)
                .cornerRadius(20)
                .padding()
                
                // Settings List
                VStack(spacing: 0) {
                    SettingsRow(icon: "bell.fill", title: "Notifications", color: .green)
                    Divider()
                    SettingsRow(icon: "lock.fill", title: "Privacy", color: .green)
                    Divider()
                    SettingsRow(icon: "questionmark.circle.fill", title: "Help & Support", color: .green)
                    Divider()
                    SettingsRow(icon: "info.circle.fill", title: "About HomShelf", color: .green)
                }
                .background(Color.white)
                .cornerRadius(20)
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}

// Settings Row Component
struct SettingsRow: View {
    var icon: String
    var title: String
    var color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            Text(title)
                .font(.system(size: 16))
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14))
        }
        .padding()
    }
}
