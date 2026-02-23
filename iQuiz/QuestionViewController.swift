//
//  QuestionViewController.swift
//  iQuiz
//
//  Created by Eric Chou on 2/22/26.
//

import UIKit

class QuestionViewController: UIViewController {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answersStackView: UIStackView!
    @IBOutlet weak var submitButton: UIButton!
    
    var quiz: Quiz!
    var currentQuestionIndex: Int = 0
    var userAnswers: [Int] = []
    var selectedAnswerIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure quiz is set before setting up the view
        guard quiz != nil else {
            fatalError("Quiz must be set before view loads. Make sure prepare(for segue:) sets the quiz property.")
        }
        
        setupNavigationBar()
        setupQuestion()
        setupSwipeGestures()
    }
    
    private func setupNavigationBar() {
        title = "Question \(currentQuestionIndex + 1) of \(quiz.questions.count)"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
    }
    
    private func setupQuestion() {
        let question = quiz.questions[currentQuestionIndex]
        questionLabel.text = question.text
        
        // Clear previous answer buttons
        answersStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Create answer buttons
        for (index, answer) in question.answers.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(answer, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.lineBreakMode = .byWordWrapping
            button.contentHorizontalAlignment = .left
            button.contentVerticalAlignment = .center
            button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
            button.backgroundColor = .systemGray6
            button.layer.cornerRadius = 8
            button.tag = index
            button.addTarget(self, action: #selector(answerSelected(_:)), for: .touchUpInside)
            
            answersStackView.addArrangedSubview(button)
            
            // Add height constraint to ensure all buttons are the same size
            // Do this after adding to stack view so constraints work properly
            button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        }
        
        submitButton.isEnabled = false
        submitButton.alpha = 0.5
    }
    
    @objc private func answerSelected(_ sender: UIButton) {
        // Deselect all buttons
        answersStackView.arrangedSubviews.forEach { view in
            if let button = view as? UIButton {
                button.backgroundColor = .systemGray6
                button.setTitleColor(.label, for: .normal)
            }
        }
        
        // Select the tapped button
        sender.backgroundColor = .systemBlue
        sender.setTitleColor(.white, for: .normal)
        selectedAnswerIndex = sender.tag
        submitButton.isEnabled = true
        submitButton.alpha = 1.0
    }
    
    @objc private func backTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func submitTapped(_ sender: UIButton) {
        guard let selectedIndex = selectedAnswerIndex else { return }
        
        userAnswers.append(selectedIndex)
        
        performSegue(withIdentifier: "ShowAnswer", sender: self)
    }
    
    private func setupSwipeGestures() {
        // Swipe right to submit
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        // Swipe left to abandon quiz
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
    }
    
    @objc private func handleSwipeRight() {
        if let selectedIndex = selectedAnswerIndex {
            submitTapped(submitButton)
        }
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
        if segue.identifier == "ShowAnswer",
           let answerVC = segue.destination as? AnswerViewController {
            answerVC.quiz = quiz
            answerVC.currentQuestionIndex = currentQuestionIndex
            answerVC.userAnswers = userAnswers
        }
    }
}
