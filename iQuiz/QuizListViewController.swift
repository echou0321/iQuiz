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
    private let settingsManager = SettingsManager.shared
    private var refreshTimer: Timer?
    private var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupToolbar()
        setupPullToRefresh()
        setupNotifications()
        loadQuizzesFromNetwork()
        setupTimedRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTimedRefresh()
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        refreshTimer?.invalidate()
        refreshTimer = nil
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func appDidBecomeActive() {
        setupTimedRefresh()
        loadQuizzesFromNetwork(silent: true)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "QuizCell")
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
    
    private func setupPullToRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshQuizzes), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(quizzesUpdated),
            name: QuizData.quizzesUpdatedNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkErrorOccurred),
            name: QuizData.networkErrorNotification,
            object: nil
        )
    }
    
    private func setupTimedRefresh() {
        // Invalidate existing timer
        refreshTimer?.invalidate()
        
        let interval = settingsManager.refreshInterval
        if interval > 0 {
            refreshTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
                self?.loadQuizzesFromNetwork(silent: true)
            }
        }
    }
    
    private func loadQuizzesFromNetwork(silent: Bool = false) {
        quizData.loadQuizzesFromNetwork { [weak self] success in
            DispatchQueue.main.async {
                // Error notification will be handled by networkErrorOccurred if not silent
            }
        }
    }
    
    @objc private func refreshQuizzes() {
        loadQuizzesFromNetwork(silent: false)
    }
    
    @objc private func quizzesUpdated() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    @objc private func networkErrorOccurred(_ notification: Notification) {
        DispatchQueue.main.async {
            self.refreshControl?.endRefreshing()
            
            let error = notification.userInfo?["error"] as? NetworkError
            let message = error?.errorDescription ?? "Network error occurred"
            
            let alert = UIAlertController(
                title: "Network Error",
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    @objc private func settingsTapped() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowQuestion",
           let questionVC = segue.destination as? QuestionViewController {
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
        
        let title = quiz.title.count > 30 ? String(quiz.title.prefix(30)) : quiz.title
        cell?.textLabel?.text = title
        cell?.detailTextLabel?.text = quiz.descValue
        
        // Create icon image from emoji
        let iconSize = CGSize(width: 40, height: 40)
        let renderer = UIGraphicsImageRenderer(size: iconSize)
        let iconImage = renderer.image { context in
            let font = UIFont.systemFont(ofSize: 30)
            let attributes: [NSAttributedString.Key: Any] = [.font: font]
            let attributedString = NSAttributedString(string: quiz.iconValue, attributes: attributes)
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
