//
//  QuizData.swift
//  iQuiz
//
//  Created by Eric Chou on 2/22/26.
//

import Foundation

class QuizData {
    static let shared = QuizData()
    
    var quizzes: [Quiz] = []
    
    private let networkService = NetworkService.shared
    private let settingsManager = SettingsManager.shared
    private let localStorage = LocalStorageService.shared
    
    // Notification names
    static let quizzesUpdatedNotification = Notification.Name("quizzesUpdated")
    static let networkErrorNotification = Notification.Name("networkError")
    
    private init() {
        if let localQuizzes = localStorage.loadQuizzes(), !localQuizzes.isEmpty {
            quizzes = localQuizzes
        } else {
            loadSampleData()
        }
        loadQuizzesFromNetwork(silent: true)
    }
    
    func loadQuizzesFromNetwork(silent: Bool = false, completion: ((Bool) -> Void)? = nil) {
        let url = settingsManager.dataSourceURL
        networkService.fetchQuizzes(from: url) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let quizzes):
                    self?.quizzes = quizzes
                    _ = self?.localStorage.saveQuizzes(quizzes)
                    NotificationCenter.default.post(name: QuizData.quizzesUpdatedNotification, object: nil)
                    completion?(true)
                case .failure(let error):
                    if let localQuizzes = self?.localStorage.loadQuizzes(), !localQuizzes.isEmpty {
                        self?.quizzes = localQuizzes
                        NotificationCenter.default.post(name: QuizData.quizzesUpdatedNotification, object: nil)
                    }
                    if !silent {
                        NotificationCenter.default.post(
                            name: QuizData.networkErrorNotification,
                            object: nil,
                            userInfo: ["error": error]
                        )
                    }
                    completion?(false)
                }
            }
        }
    }
    
    private func loadSampleData() {
        let mathQuiz = Quiz(
            title: "Mathematics",
            desc: "Test your math skills",
            icon: "🔢",
            questions: [
                Question(
                    text: "What is 2 + 2?",
                    answers: ["3", "4", "5", "6"],
                    answer: 1
                ),
                Question(
                    text: "What is 5 × 3?",
                    answers: ["10", "15", "20", "25"],
                    answer: 1
                ),
                Question(
                    text: "What is 10 ÷ 2?",
                    answers: ["3", "4", "5", "6"],
                    answer: 2
                )
            ]
        )

        let marvelQuiz = Quiz(
            title: "Marvel Super Heroes",
            desc: "Test your Marvel knowledge",
            icon: "🦸",
            questions: [
                Question(
                    text: "What is Iron Man's real name?",
                    answers: ["Steve Rogers", "Tony Stark", "Bruce Banner", "Peter Parker"],
                    answer: 1
                ),
                Question(
                    text: "What is Captain America's shield made of?",
                    answers: ["Steel", "Vibranium", "Adamantium", "Titanium"],
                    answer: 1
                ),
                Question(
                    text: "Who is the God of Thunder?",
                    answers: ["Loki", "Thor", "Odin", "Hela"],
                    answer: 1
                )
            ]
        )
        
        let scienceQuiz = Quiz(
            title: "Science",
            desc: "Test your science knowledge",
            icon: "🔬",
            questions: [
                Question(
                    text: "What is the chemical symbol for water?",
                    answers: ["H2O", "CO2", "O2", "NaCl"],
                    answer: 0
                ),
                Question(
                    text: "What planet is known as the Red Planet?",
                    answers: ["Venus", "Mars", "Jupiter", "Saturn"],
                    answer: 1
                ),
                Question(
                    text: "What is the speed of light?",
                    answers: ["300,000 km/s", "150,000 km/s", "450,000 km/s", "600,000 km/s"],
                    answer: 0
                )
            ]
        )
        
        quizzes = [mathQuiz, marvelQuiz, scienceQuiz]
    }
}
