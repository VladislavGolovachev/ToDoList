//
//  MainViewConstants.swift
//  ToDoList
//
//  Created by Владислав Головачев on 04.09.2024.
//

import UIKit

enum MainViewConstants {
    enum Color {
        static let background = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        static let cell = UIColor.white
        static let separator = UIColor.separator.withAlphaComponent(0.1)
        
        enum Text {
            static let primary = UIColor.black
            static let secondary = UIColor.lightGray
            static let time = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        }
    }
    enum Font {
        static let primary = UIFont.systemFont(ofSize: 17.0, weight: .medium)
        static let secondary = UIFont.systemFont(ofSize: 12.0, weight: .semibold)
        static let time = UIFont.systemFont(ofSize: 12.0, weight: .medium)
    }
    enum CollectionView {
        static let minimumLineSpacing = 20.0
    }
    enum Cell {
        static let padding = 20.0
        static let contentPadding = 20.0
        static let cornerRadius = 10.0
        static let separatorHeight = 1.0
        
        enum VerticalSpacing {
            static let afterReminder = 5.0
            static let common = 15.0
        }
        enum HorizontalSpacing {
            static let checkbox = 5.0
            static let timeLabel = 5.0
        }
    }
    enum Checkbox {
        enum Name {
            static let checked = "CheckedCheckbox"
            static let unchecked = "UncheckedCheckbox"
        }
        static let width = 26.0
        static let centerYOffset = 40.0
    }
}
