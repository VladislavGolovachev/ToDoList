//
//  MainModuleConstants.swift
//  ToDoList
//
//  Created by Владислав Головачев on 04.09.2024.
//

import UIKit

enum MainViewConstants {
    static let padding = 20.0
    static let tableLineSpacing = 20.0
    static let initialReminderText = "New reminder"
    
    enum Color {
        static let background   = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        static let time         = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        static let date         = UIColor.lightGray
    }
    enum Font {
        static let date = UIFont.systemFont(ofSize: 12.0, weight: .semibold)
        static let time = UIFont.systemFont(ofSize: 12.0, weight: .medium)
    }
}

enum ReminderState: Int {
    case notSpecified
    case notCompleted
    case completed
}
