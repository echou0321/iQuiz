//
//  Models.swift
//  iQuiz
//
//  Created by Eric Chou on 2/22/26.
//

import Foundation

struct Quiz {
    let title: String
    let description: String
    let icon: String
    let questions: [Question]
}

struct Question {
    let text: String
    let answers: [String]
    let correctAnswerIndex: Int
}
