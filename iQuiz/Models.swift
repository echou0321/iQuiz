//
//  Models.swift
//  iQuiz
//
//  Created by Eric Chou on 2/22/26.
//

import Foundation

struct Quiz: Codable {
    let title: String
    let desc: String?  // Make optional to handle both "desc" and "description"
    let description: String?  // Also check for "description"
    let icon: String?  // Make optional since JSON might not have it
    let questions: [Question]
    
    // Computed property for compatibility with existing code
    var descValue: String {
        return desc ?? description ?? "No description"
    }
    
    // Computed property for icon with default
    var iconValue: String {
        return icon ?? "📚"  // Default icon if not provided
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case desc
        case description
        case icon
        case questions
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        desc = try? container.decode(String.self, forKey: .desc)
        description = try? container.decode(String.self, forKey: .description)
        icon = try? container.decode(String.self, forKey: .icon)
        questions = try container.decode([Question].self, forKey: .questions)
    }
    
    // Convenience initializer for sample data
    init(title: String, desc: String, icon: String, questions: [Question]) {
        self.title = title
        self.desc = desc
        self.description = nil
        self.icon = icon
        self.questions = questions
    }
}

struct Question: Codable {
    let text: String
    let answers: [String]
    let answer: String?  // JSON uses "answer" as a string like "1", "2", etc.
    let correctAnswerIndex: Int?  // Also check for "correctAnswerIndex" as Int
    
    var correctAnswer: Int {
        // Convert string answer to Int, or use correctAnswerIndex if available
        if let answerStr = answer, let answerInt = Int(answerStr) {
            return answerInt
        }
        return correctAnswerIndex ?? 0
    }
    
    enum CodingKeys: String, CodingKey {
        case text
        case answers
        case answer
        case correctAnswerIndex
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        answers = try container.decode([String].self, forKey: .answers)
        
        // Try to decode answer as String first (from JSON), then as Int
        if let answerString = try? container.decode(String.self, forKey: .answer) {
            answer = answerString
        } else if let answerInt = try? container.decode(Int.self, forKey: .answer) {
            answer = String(answerInt)
        } else {
            answer = nil
        }
        
        correctAnswerIndex = try? container.decode(Int.self, forKey: .correctAnswerIndex)
    }
    
    // Convenience initializer for sample data (accepts Int)
    init(text: String, answers: [String], answer: Int) {
        self.text = text
        self.answers = answers
        self.answer = String(answer)
        self.correctAnswerIndex = nil
    }
}
