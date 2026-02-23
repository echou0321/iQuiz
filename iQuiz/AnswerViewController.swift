//
//  AnswerViewController.swift
//  iQuiz
//
//  Created by Eric Chou on 2/22/26.
//

import UIKit

class AnswerViewController: UIViewController {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var correctAnswerLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    var quiz: Quiz!
    var currentQuestionIndex: Int = 0
    var userAnswers: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        displayAnswer()
        setupSwipeGestures()
    }
    
    private func setupNavigationBar() {
        title = "Answer"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
    }
    
    private func displayAnswer() {
        let question = quiz.questions[currentQuestionIndex]
        let userAnswerIndex = userAnswers[currentQuestionIndex]
        let correctAnswerIndex = question.correctAnswerIndex
        
        questionLabel.text = question.text
        correctAnswerLabel.text = "Correct Answer: \(question.answers[correctAnswerIndex])"
        
        if userAnswerIndex == correctAnswerIndex {
            resultLabel.text = "Correct! ✓"
            resultLabel.textColor = .systemGreen
        } else {
            resultLabel.text = "Incorrect! ✗"
            resultLabel.textColor = .systemRed
        }
    }
    
    @objc private func backTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func nextTapped(_ sender: UIButton) {
        if currentQuestionIndex < quiz.questions.count - 1 {
            // Go to next question
            guard let storyboard = storyboard else { return }
            let questionVC = storyboard.instantiateViewController(withIdentifier: "QuestionViewController") as! QuestionViewController
            questionVC.quiz = quiz
            questionVC.currentQuestionIndex = currentQuestionIndex + 1
            questionVC.userAnswers = userAnswers
            
            navigationController?.pushViewController(questionVC, animated: true)
        } else {
            // Go to finished scene
            performSegue(withIdentifier: "ShowFinished", sender: self)
        }
    }
    
    private func setupSwipeGestures() {
        // Swipe right to go to next
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        // Swipe left to abandon quiz
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
    }
    
    @objc private func handleSwipeRight() {
        nextTapped(nextButton)
    }
    
    @objc private func handleSwipeLeft() {
        let alert = UIAlertController(
            title: "Abandon Quiz?",
            message: "Are you sure you want to abandon this quiz? Your progress will be lost.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Abandon", style: .destructive) { _ in
            self.navigationController?.popToRootViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowFinished",
           let finishedVC = segue.destination as? FinishedViewController {
            finishedVC.quiz = quiz
            finishedVC.userAnswers = userAnswers
        }
    }
}
