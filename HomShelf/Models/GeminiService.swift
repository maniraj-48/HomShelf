import Foundation

class GeminiService {
    
    static let shared = GeminiService()
    
    // 🔑 Add your API key here
    private let apiKey = "YOUR_API_KEY_HERE"
    private let apiURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
    
    // Check current price for item
    func checkPrice(itemName: String, quantity: String, completion: @escaping (PriceResult?) -> Void) {
        
        let prompt = """
        Search for the current retail price of "\(itemName)" (\(quantity)) in USA stores right now.
        
        Find the TOP 5 cheapest places to buy this item online and in stores.
        Include stores like Walmart, Amazon, Costco, Target, Kroger, Whole Foods, or any other relevant store that sells this item cheapest.
        
        Respond ONLY in this exact format with no extra text or explanation:
        STORE_1_NAME: StoreName
        STORE_1_PRICE: $X.XX
        STORE_2_NAME: StoreName
        STORE_2_PRICE: $X.XX
        STORE_3_NAME: StoreName
        STORE_3_PRICE: $X.XX
        STORE_4_NAME: StoreName
        STORE_4_PRICE: $X.XX
        STORE_5_NAME: StoreName
        STORE_5_PRICE: $X.XX
        CHEAPEST_STORE: StoreName
        CHEAPEST_PRICE: $X.XX
        AVERAGE_PRICE: $X.XX
        RECOMMENDATION: One sentence recommendation on best place to buy.
        """
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]
        
        guard let url = URL(string: "\(apiURL)?key=\(apiKey)") else {
            completion(nil)
            return
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let candidates = json["candidates"] as? [[String: Any]],
               let content = candidates.first?["content"] as? [String: Any],
               let parts = content["parts"] as? [[String: Any]],
               let text = parts.first?["text"] as? String {
                
                let result = PriceResult.parse(from: text)
                completion(result)
            } else {
                completion(nil)
            }
        }.resume()
    }
}

// Price Result Model
struct PriceResult {
    var stores: [(name: String, price: String)] = []
    var cheapestStore: String = "N/A"
    var cheapestPrice: String = "N/A"
    var averagePrice: String = "N/A"
    var recommendation: String = "N/A"
    
    static func parse(from text: String) -> PriceResult {
        var result = PriceResult()
        let lines = text.components(separatedBy: "\n")
        
        var storeNames: [String] = []
        var storePrices: [String] = []
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.contains("STORE_") && trimmed.contains("_NAME:") {
                let value = trimmed.components(separatedBy: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
                storeNames.append(value)
            } else if trimmed.contains("STORE_") && trimmed.contains("_PRICE:") {
                let value = trimmed.components(separatedBy: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
                storePrices.append(value)
            } else if trimmed.contains("CHEAPEST_STORE:") {
                result.cheapestStore = trimmed.components(separatedBy: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
            } else if trimmed.contains("CHEAPEST_PRICE:") {
                result.cheapestPrice = trimmed.components(separatedBy: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
            } else if trimmed.contains("AVERAGE_PRICE:") {
                result.averagePrice = trimmed.components(separatedBy: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
            } else if trimmed.contains("RECOMMENDATION:") {
                result.recommendation = trimmed.components(separatedBy: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
            }
        }
        
        // Combine store names and prices
        for i in 0..<min(storeNames.count, storePrices.count) {
            result.stores.append((name: storeNames[i], price: storePrices[i]))
        }
        
        return result
    }
}
