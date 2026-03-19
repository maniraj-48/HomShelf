import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    @State private var goToWardboard = false
    
    var body: some View {
        if goToWardboard {
            MainTabView()
        } else {
            ZStack {
                // Background color
                Color(red: 0.95, green: 0.98, blue: 0.95)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Logo Icon
                    // Logo Icon — using app icon image
                    Image("homself_icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .cornerRadius(24)
                        .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 5)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.spring(duration: 0.8), value: isAnimating)
                    
                    // App Name
                    Text("HomShelf")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.black)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(.easeIn(duration: 0.8).delay(0.3), value: isAnimating)
                    
                    // Tagline
                    Text("Your Smart Pantry")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gray)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(.easeIn(duration: 0.8).delay(0.5), value: isAnimating)
                    
                    Spacer()
                    
                    // Go to Wardboard Button
                    Button(action: {
                        goToWardboard = true
                    }) {
                        Text("Go to Wardboard")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(30)
                            .padding(.horizontal, 40)
                    }
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.easeIn(duration: 0.8).delay(0.7), value: isAnimating)
                    
                    Spacer()
                        .frame(height: 40)
                }
            }
            .onAppear {
                isAnimating = true
            }
        }
    }
}

#Preview {
    SplashView()
}
