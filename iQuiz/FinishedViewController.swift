//
//  FinishedViewController.swift
//  iQuiz
//
//  Created by Eric Chou on 2/22/26.
//

import UIKit

class FinishedViewController: UIViewController {
    
    @IBOutlet weak var performanceLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    var quiz: Quiz!
    var userAnswers: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        displayResults()
    }
    
    private func setupNavigationBar() {
        title = "Quiz Complete"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
    }
    
    private func displayResults() {
        let correctCount = calculateCorrectAnswers()
        let totalQuestions = quiz.questions.count
        let percentage = Double(correctCount) / Double(totalQuestions)
        
        scoreLabel.text = "\(correctCount) of \(totalQuestions) correct"
        
        if percentage == 1.0 {
            performanceLabel.text = "Perfect!"
        } else if percentage >= 0.8 {
            performanceLabel.text = "Almost!"
        } else if percentage >= 0.6 {
            performanceLabel.text = "Good job!"
        } else {
            performanceLabel.text = "Keep practicing!"
        }
        
        nextButton.setTitle("Back to Quiz List", for: .normal)
    }
    
    private func calculateCorrectAnswers() -> Int {
        var correctCount = 0
        for (index, userAnswer) in userAnswers.enumerated() {
            if userAnswer == quiz.questions[index].correctAnswer {
                correctCount += 1
            }
        }
        return correctCount
    }
    
    @objc private func backTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func nextTapped(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
}
