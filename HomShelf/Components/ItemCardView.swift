import SwiftUI

struct ItemCardView: View {
    var item: GroceryItem
    
    // Color based on percentage
    var progressColor: Color {
        if item.percentageLeft > 50 { return .green }
        else if item.percentageLeft > 20 { return .orange }
        else { return .red }
    }
    
    // Background color based on category
    var categoryColor: Color {
        switch item.category {
        case "Dairy": return Color.blue.opacity(0.15)
        case "Produce": return Color.green.opacity(0.15)
        case "Grains": return Color.yellow.opacity(0.15)
        case "Meat": return Color.red.opacity(0.15)
        case "Snacks": return Color.orange.opacity(0.15)
        default: return Color.gray.opacity(0.15)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            ZStack(alignment: .topTrailing) {
                
                if let fileName = item.imageFileName,
                   let uiImage = ImageStorage.loadImage(fileName: fileName) {
                    // User added photo → show it
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    // No photo → show first letter or emoji
                    RoundedRectangle(cornerRadius: 16)
                        .fill(categoryColor)
                        .frame(height: 140)
                        .overlay(
                            VStack(spacing: 6) {
                                // Shows emoji if user set one
                                // OR first letter by default
                                Text(item.displayEmoji)
                                    .font(.system(size: 44, weight: .bold))
                                    .foregroundColor(.black.opacity(0.6))
                                
                                // Item name always shown
                                Text(item.name)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.black.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 8)
                            }
                        )
                }
                
                // Status dot top right
                Circle()
                    .fill(progressColor)
                    .frame(width: 12, height: 12)
                    .padding(10)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text(item.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                
                HStack {
                    Text(item.category)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("$\(item.pricePaid, specifier: "%.2f")")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.black)
                }
                
                HStack {
                    Text("\(Int(item.percentageLeft))% left")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(progressColor)
                    Spacer()
                    Text(item.statusText)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(progressColor)
                            .frame(
                                width: geometry.size.width * CGFloat(item.percentageLeft / 100),
                                height: 6
                            )
                    }
                }
                .frame(height: 6)
                .padding(.top, 2)
            }
            .padding(10)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
