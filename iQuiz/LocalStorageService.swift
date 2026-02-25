//
//  LocalStorageService.swift
//  iQuiz
//
//  Created by Eric Chou on 2/22/26.
//

import Foundation

class LocalStorageService {
    static let shared = LocalStorageService()
    
    private let fileName = "quizzes.json"
    
    private var fileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    private init() {}
    
    func saveQuizzes(_ quizzes: [Quiz]) -> Bool {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(quizzes)
            try data.write(to: fileURL, options: .atomic)
            return true
        } catch {
            print("Error saving quizzes to local storage: \(error.localizedDescription)")
            return false
        }
    }
    
    func loadQuizzes() -> [Quiz]? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let quizzes = try decoder.decode([Quiz].self, from: data)
            return quizzes
        } catch {
            print("Error loading quizzes from local storage: \(error.localizedDescription)")
            return nil
        }
    }
}
