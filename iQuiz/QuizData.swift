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
    
    private init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        let mathQuiz = Quiz(
            title: "Mathematics",
            description: "Test your math skills",
            icon: "🔢",
            questions: [
                Question(
                    text: "What is 2 + 2?",
                    answers: ["3", "4", "5", "6"],
                    correctAnswerIndex: 1
                ),
                Question(
                    text: "What is 5 × 3?",
                    answers: ["10", "15", "20", "25"],
                    correctAnswerIndex: 1
                ),
                Question(
                    text: "What is 10 ÷ 2?",
                    answers: ["3", "4", "5", "6"],
                    correctAnswerIndex: 2
                )
            ]
        )

        let marvelQuiz = Quiz(
            title: "Marvel Super Heroes",
            description: "Test your Marvel knowledge",
            icon: "🦸",
            questions: [
                Question(
                    text: "What is Iron Man's real name?",
                    answers: ["Steve Rogers", "Tony Stark", "Bruce Banner", "Peter Parker"],
                    correctAnswerIndex: 1
                ),
                Question(
                    text: "What is Captain America's shield made of?",
                    answers: ["Steel", "Vibranium", "Adamantium", "Titanium"],
                    correctAnswerIndex: 1
                ),
                Question(
                    text: "Who is the God of Thunder?",
                    answers: ["Loki", "Thor", "Odin", "Hela"],
                    correctAnswerIndex: 1
                )
            ]
        )
        
        let scienceQuiz = Quiz(
            title: "Science",
            description: "Test your science knowledge",
            icon: "🔬",
            questions: [
                Question(
                    text: "What is the chemical symbol for water?",
                    answers: ["H2O", "CO2", "O2", "NaCl"],
                    correctAnswerIndex: 0
                ),
                Question(
                    text: "What planet is known as the Red Planet?",
                    answers: ["Venus", "Mars", "Jupiter", "Saturn"],
                    correctAnswerIndex: 1
                ),
                Question(
                    text: "What is the speed of light?",
                    answers: ["300,000 km/s", "150,000 km/s", "450,000 km/s", "600,000 km/s"],
                    correctAnswerIndex: 0
                )
            ]
        )
        
        quizzes = [mathQuiz, marvelQuiz, scienceQuiz]
    }
}
