//
//  API.swift
//  newSearchJoselyn
//
//  Created by Joselyn Cordero on 02/08/24.
//

import Foundation

final class APIModel {
    private let apiKey = "cbee1b7a7amsh7236e8240980683p176f6ejsnb5c4411941bb"
        private let apiHost = "aviation-reference-data.p.rapidapi.com"
        private let baseURL = "https://aviation-reference-data.p.rapidapi.com/airports/search"
        
        func searchAirports(latitude: Double, longitude: Double, radius: Int, completion: @escaping (Result<[Airport], Error>) -> Void) {
            guard let url = URL(string: "\(baseURL)?lat=\(latitude)&lon=\(longitude)&radius=\(radius)") else {
                print("Invalid URL")
                return
            }
            
            var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = [
                "x-rapidapi-key": apiKey,
                "x-rapidapi-host": apiHost
            ]
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let response = response as? HTTPURLResponse, let data = data else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response or data"])
                    completion(.failure(error))
                    return
                }
                
                print("Response Code: \(response.statusCode)")
                
                if let dataString = String(data: data, encoding: .utf8) {
                    print("Data: \(dataString)")
                }
                
                do {
                   
                    let decoder = JSONDecoder()
                    let airports = try decoder.decode([Airport].self, from: data)
                    completion(.success(airports))
                } catch {
                    // Maneja el error de decodificación
                    completion(.failure(error))
                    if let decodingError = error as? DecodingError {
                        switch decodingError {
                        case .dataCorrupted(let context):
                            print("Data corrupted: \(context)")
                        case .keyNotFound(let key, let context):
                            print("Key '\(key)' not found: \(context)")
                        case .valueNotFound(let value, let context):
                            print("Value '\(value)' not found: \(context)")
                        case .typeMismatch(let type, let context):
                            print("Type '\(type)' mismatch: \(context)")
                        @unknown default:
                            print("Unknown decoding error: \(error)")
                        }
                    } else {
                        print("Unexpected error: \(error)")
                    }
                }
            }
            
            dataTask.resume()
        }
}

class AirportDataManager {
    static let shared = AirportDataManager()
    
    private init() {}
    
    var airports: [Airport] = []
}
