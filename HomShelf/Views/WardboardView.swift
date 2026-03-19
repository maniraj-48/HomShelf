import SwiftUI

struct WardboardView: View {
    @ObservedObject var store: ItemStore
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var showAddItem = false
    
    var categories: [String] {
        var cats = ["All"]
        let itemCategories = store.items.map { $0.category }
        let unique = Array(Set(itemCategories)).sorted()
        cats.append(contentsOf: unique)
        return cats
    }
    
    // Filter items based on search and category
    var filteredItems: [GroceryItem] {
        store.items.filter { item in
            let matchesSearch = searchText.isEmpty ||
                item.name.lowercased().contains(searchText.lowercased())
            let matchesCategory = selectedCategory == "All" ||
                item.category == selectedCategory
            return matchesSearch && matchesCategory
        }
    }
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(red: 0.95, green: 0.98, blue: 0.95)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Header
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.green)
                                .frame(width: 36, height: 36)
                            Image(systemName: "cabinet.fill")
                                .foregroundColor(.white)
                        }
                        Text("HomShelf")
                            .font(.system(size: 24, weight: .bold))
                        Spacer()
                        Image(systemName: "bell")
                            .font(.system(size: 20))
                        Image(systemName: "gearshape")
                            .font(.system(size: 20))
                            .padding(.leading, 10)
                    }
                    .padding()
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search inventory...", text: $searchText)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(30)
                    .padding(.horizontal)
                    
                    // Category Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(categories, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = category
                                }) {
                                    Text(category)
                                        .font(.system(size: 14, weight: .medium))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            selectedCategory == category ?
                                            Color.green : Color.white
                                        )
                                        .foregroundColor(
                                            selectedCategory == category ?
                                            .white : .black
                                        )
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // Items Grid
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filteredItems) { item in
                                NavigationLink(destination: ItemDetailView(item: item, store: store)) {
                                    ItemCardView(item: item)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
                
                // Floating + Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showAddItem = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.green)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 80)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddItem) {
                AddItemView(store: store)
            }
        }
    }
}

#Preview {
    WardboardView(store: ItemStore())
}
