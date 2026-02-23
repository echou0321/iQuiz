//
//  QuizListViewController.swift
//  iQuiz
//
//  Created by Eric Chou on 2/22/26.
//

import UIKit

class QuizListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let quizData = QuizData.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupToolbar()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "QuizCell")
        // Enable subtitle style for cells
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
    }
    
    private func setupToolbar() {
        let settingsButton = UIBarButtonItem(
            title: "Settings",
            style: .plain,
            target: self,
            action: #selector(settingsTapped)
        )
        
        navigationItem.rightBarButtonItem = settingsButton
    }
    
    @objc private func settingsTapped() {
        let alert = UIAlertController(
            title: "Settings",
            message: "Settings go here",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowQuestion",
           let questionVC = segue.destination as? QuestionViewController {
            // Get indexPath from sender (passed from didSelectRowAt) or from selected row
            let indexPath: IndexPath
            if let senderIndexPath = sender as? IndexPath {
                indexPath = senderIndexPath
            } else if let selectedIndexPath = tableView.indexPathForSelectedRow {
                indexPath = selectedIndexPath
            } else {
                fatalError("Could not determine selected row for segue")
            }
            
            let quiz = quizData.quizzes[indexPath.row]
            questionVC.quiz = quiz
            questionVC.currentQuestionIndex = 0
            questionVC.userAnswers = []
        }
    }
}

extension QuizListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizData.quizzes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "QuizCell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "QuizCell")
        }
        let quiz = quizData.quizzes[indexPath.row]
        
        // Truncate title to 30 characters
        let title = quiz.title.count > 30 ? String(quiz.title.prefix(30)) : quiz.title
        cell?.textLabel?.text = title
        cell?.detailTextLabel?.text = quiz.description
        
        // Set icon as emoji using attributed string or image view
        // Create an image from emoji text
        let iconSize = CGSize(width: 40, height: 40)
        let renderer = UIGraphicsImageRenderer(size: iconSize)
        let iconImage = renderer.image { context in
            let font = UIFont.systemFont(ofSize: 30)
            let attributes: [NSAttributedString.Key: Any] = [.font: font]
            let attributedString = NSAttributedString(string: quiz.icon, attributes: attributes)
            let textSize = attributedString.size()
            let textRect = CGRect(
                x: (iconSize.width - textSize.width) / 2,
                y: (iconSize.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            attributedString.draw(in: textRect)
        }
        cell?.imageView?.image = iconImage
        
        // Configure cell appearance
        cell?.accessoryType = .disclosureIndicator
        
        return cell ?? UITableViewCell()
    }
}

extension QuizListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowQuestion", sender: indexPath)
    }
}
