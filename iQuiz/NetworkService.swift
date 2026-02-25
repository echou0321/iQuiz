//
//  NetworkService.swift
//  iQuiz
//
//  Created by Eric Chou on 2/22/26.
//

import Foundation

class NetworkService {
    static let shared = NetworkService()
    
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10.0
        configuration.timeoutIntervalForResource = 30.0
        self.session = URLSession(configuration: configuration)
    }
    
    func fetchQuizzes(from urlString: String, completion: @escaping (Result<[Quiz], NetworkError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                    completion(.failure(.noInternetConnection))
                } else {
                    completion(.failure(.networkError(error.localizedDescription)))
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode != 200 {
                completion(.failure(.httpError(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let quizzes = try JSONDecoder().decode([Quiz].self, from: data)
                completion(.success(quizzes))
            } catch {
                do {
                    struct QuizResponse: Codable {
                        let quizzes: [Quiz]?
                        let topics: [Quiz]?
                    }
                    let response = try JSONDecoder().decode(QuizResponse.self, from: data)
                    if let quizzes = response.quizzes ?? response.topics {
                        completion(.success(quizzes))
                    } else {
                        completion(.failure(.decodingError("No quizzes found in response")))
                    }
                } catch {
                    print("Decoding error details: \(error)")
                    if let decodingError = error as? DecodingError {
                        switch decodingError {
                        case .keyNotFound(let key, let context):
                            completion(.failure(.decodingError("Missing key '\(key.stringValue)' at \(context.debugDescription)")))
                        case .typeMismatch(let type, let context):
                            completion(.failure(.decodingError("Type mismatch for type \(type) at \(context.debugDescription)")))
                        case .valueNotFound(let type, let context):
                            completion(.failure(.decodingError("Value not found for type \(type) at \(context.debugDescription)")))
                        case .dataCorrupted(let context):
                            completion(.failure(.decodingError("Data corrupted: \(context.debugDescription)")))
                        @unknown default:
                            completion(.failure(.decodingError(error.localizedDescription)))
                        }
                    } else {
                        completion(.failure(.decodingError(error.localizedDescription)))
                    }
                }
            }
        }
        
        task.resume()
    }
}

enum NetworkError: LocalizedError {
    case invalidURL
    case noInternetConnection
    case networkError(String)
    case httpError(Int)
    case noData
    case decodingError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL. Please check the URL in settings."
        case .noInternetConnection:
            return "No internet connection available. Please check your network settings."
        case .networkError(let message):
            return "Network error: \(message)"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .noData:
            return "No data received from server."
        case .decodingError(let message):
            return "Failed to parse data: \(message)"
        }
    }
}
