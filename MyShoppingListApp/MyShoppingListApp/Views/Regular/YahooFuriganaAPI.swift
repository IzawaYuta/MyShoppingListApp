//
//  YahooFuriganaAPI.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/10/19.
//

import Foundation

//struct YahooFuriganaAPI {
//    static let appID = "dj00aiZpPVZ2T2tyZlFFZ1lheSZzPWNvbnN1bWVyc2VjcmV0Jng9NTM-"
//    
//    static func fetchFurigana(for text: String) async throws -> String {
//        guard let url = URL(string: "https://jlp.yahooapis.jp/FuriganaService/V2/furigana") else {
//            throw URLError(.badURL)
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue(appID, forHTTPHeaderField: "X-Yahoo-App-Id")
//        
//        let body: [String: Any] = [
//            "id": "furigana-req",
//            "jsonrpc": "2.0",
//            "method": "jlp.furiganaservice.furigana",
//            "params": [
//                "q": text,
//                "grade": 1
//            ]
//        ]
//        request.httpBody = try JSONSerialization.data(withJSONObject: body)
//        
//        let (data, response) = try await URLSession.shared.data(for: request)
//        
//        if let http = response as? HTTPURLResponse {
//            print("📡 [HTTP STATUS]:", http.statusCode)
//            print("📩 [HEADERS]:", http.allHeaderFields)
//        }
//        if let bodyString = String(data: data, encoding: .utf8) {
//            print("🧾 [BODY]:", bodyString)
//        }
//        
//        // 🔸 ステータスコードが200以外なら詳細をthrow
//        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
//            throw NSError(
//                domain: "YahooFuriganaAPI",
//                code: http.statusCode,
//                userInfo: [
//                    NSLocalizedDescriptionKey: "HTTP \(http.statusCode)",
//                    "responseBody": String(data: data, encoding: .utf8) ?? "(no body)"
//                ]
//            )
//        }
//        
//        struct FuriganaResponse: Codable {
//            struct Result: Codable {
//                struct Word: Codable {
//                    let surface: String
//                    let furigana: String?
//                }
//                let word: [Word]
//            }
//            let result: Result?
//        }
//        
//        let decoded = try JSONDecoder().decode(FuriganaResponse.self, from: data)
//        let joined = decoded.result?.word.map { word in
//            if let furi = word.furigana {
//                return furi
//            } else {
//                return word.surface
//            }
//        }.joined() ?? ""
//        return joined
//    }
//}

//struct FuriganaWord: Identifiable {
//    let id = UUID()
//    let surface: String
//    let furigana: String
//}
//
//struct FuriganaAPIResponse: Codable {
//    let id: String?
//    let jsonrpc: String
//    let result: FuriganaResult?
//    let error: FuriganaError?
//}

//struct FuriganaResult: Codable {
//    let word: String
//}
//
//struct FuriganaError: Codable {
//    let code: Int
//    let message: String
//}

class YahooFuriganaAPI: ObservableObject {
    @Published var furiganaWords: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // ここにあなたのClient IDを設定してください
    private let appID = "dj00aiZpPVZ2T2tyZlFFZ1lheSZzPWNvbnN1bWVyc2VjcmV0Jng9NTM-"
    
    func getFurigana(text: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            furiganaWords = ""
        }
        
        // URLにappidパラメータを追加する（これが重要！）
        guard let encodedAppID = appID.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://jlp.yahooapis.jp/FuriganaService/V2/furigana?appid=\(encodedAppID)") else {
            await MainActor.run {
                errorMessage = "Invalid URL"
                isLoading = false
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "id": "furigana-request-001",
            "jsonrpc": "2.0",
            "method": "jlp.furiganaservice.furigana",
            "params": [
                "q": text,
                "grade": 1
            ]
        ]
        
        do {
            // JSON化してリクエストに設定
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let http = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            print("📡 [HTTP STATUS]:", http.statusCode)
            if let body = String(data: data, encoding: .utf8) {
                print("📩 [BODY]:", body)
            }
            
            guard http.statusCode == 200 else {
                throw NSError(domain: "YahooFuriganaAPI", code: http.statusCode, userInfo: [
                    NSLocalizedDescriptionKey: "HTTP \(http.statusCode)"
                ])
            }
            
            // JSON全体を辞書として解析して文字列を生成
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let result = json["result"] as? [String: Any],
               let words = result["word"] as? [[String: Any]] {
                
                // 各wordのfuriganaかsurfaceを結合してひとつの文字列に
                var combinedText = ""
                for word in words {
                    if let furi = word["furigana"] as? String {
                        combinedText += furi
                    } else if let surface = word["surface"] as? String {
                        combinedText += surface
                    }
                }
                
                furiganaWords = combinedText
                
            } else {
                errorMessage = "データ解析に失敗しました"
            }
            
        } catch {
            errorMessage = "通信エラー: \(error.localizedDescription)"
            print("❌ Error:", error)
        }
        
        isLoading = false
    }
}
