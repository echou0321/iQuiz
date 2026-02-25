//
//  SettingsManager.swift
//  iQuiz
//
//  Created by Eric Chou on 2/22/26.
//

import Foundation

class SettingsManager {
    static let shared = SettingsManager()
    
    private let userDefaults = UserDefaults.standard
    
    private let defaultURLKey = "quizDataSourceURL"
    private let refreshIntervalKey = "refreshInterval"
    private let defaultURL = "http://tednewardsandbox.site44.com/questions.json"
    
    var dataSourceURL: String {
        get {
            return userDefaults.string(forKey: defaultURLKey) ?? defaultURL
        }
        set {
            userDefaults.set(newValue, forKey: defaultURLKey)
            userDefaults.synchronize()
        }
    }
    
    var refreshInterval: TimeInterval {
        get {
            if let stringValue = userDefaults.string(forKey: refreshIntervalKey),
               let interval = Double(stringValue),
               interval > 0 {
                return interval
            }
            let interval = userDefaults.double(forKey: refreshIntervalKey)
            return interval > 0 ? interval : 0
        }
        set {
            userDefaults.set(newValue, forKey: refreshIntervalKey)
            userDefaults.synchronize()
        }
    }
    
    private init() {}
}
