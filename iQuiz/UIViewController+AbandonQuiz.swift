//
//  UIViewController+AbandonQuiz.swift
//  iQuiz
//
//  Created by Eric Chou on 2/22/26.
//

import UIKit

extension UIViewController {
    func showAbandonQuizAlert() {
        let alert = UIAlertController(
            title: "Abandon Quiz?",
            message: "Are you sure you want to abandon this quiz? Your progress will be lost.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Abandon", style: .destructive) { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
}
