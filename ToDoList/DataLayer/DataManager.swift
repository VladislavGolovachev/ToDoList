//
//  DataManager.swift
//  ToDoList
//
//  Created by Владислав Головачев on 07.09.2024.
//

import Foundation

protocol DataManagerProtocol {
    var isFirstLaunch: Bool {get}
    
    func fetchTodos(amongReminders: ReminderState) throws -> [TodoEntity]
    func saveTodo(with keyedValues: [TodoKeys: Any]) throws
    func deleteTodo(for index: Int, amongReminders: ReminderState) throws
    func updateTodo(for index: Int, amongReminders: ReminderState,
                    with keyedValues: [TodoKeys: Any]) throws
    
    func getTodosCounts() throws -> [Int]
    func saveTodos(by keyedValuesArray: [[TodoKeys: Any]]) throws
}

final class DataManager: DataManagerProtocol {
    private let todoManager = TodoManager()
    
    var isFirstLaunch: Bool {
//        return true
        let key = UserDefaultsKeys.isNotFirstLaunch.rawValue
        let isNotFirstLaunch = UserDefaults.standard.bool(forKey: key)
        UserDefaults.standard.setValue(true, forKey: key)
        
        return !isNotFirstLaunch
    }
    
    func fetchTodos(amongReminders state: ReminderState) throws -> [TodoEntity] {
        let dict = dictionary(ofReminderState: state)
        let todos = try todoManager.fetch(amongObjectsWithKeyedValues: dict)
        
        return todos
    }
    
    func saveTodo(with keyedValues: [TodoKeys: Any]) throws {
        try todoManager.persist(with: converted(keyedValues))
    }
    
    func updateTodo(for index: Int, amongReminders state: ReminderState, 
                    with keyedValues: [TodoKeys: Any]) throws {
        let dict = dictionary(ofReminderState: state)
        try todoManager.update(for: index,
                               amongObjectsWithKeyedValues: dict,
                               with: converted(keyedValues))
    }
    
    func deleteTodo(for index: Int, amongReminders state: ReminderState) throws {
        let dict = dictionary(ofReminderState: state)
        try todoManager.delete(for: index, amongObjectsWithKeyedValues: dict)
    }
    
    func getTodosCounts() throws -> [Int] {
        var counts = [0, 0, 0]
        
        let dict1 = dictionary(ofReminderState: .notCompleted)
        let dict2 = dictionary(ofReminderState: .completed)
        
        counts[1] = try todoManager.count(ofObjectsWithKeyedValues: dict1)
        counts[2] = try todoManager.count(ofObjectsWithKeyedValues: dict2)
        counts[0] = counts[1] + counts[2]
        
        return counts
    }
    
    func saveTodos(by keyedValuesArray: [[TodoKeys: Any]]) throws {
        for keyedValues in keyedValuesArray {
            try saveTodo(with: keyedValues)
        }
    }
}

//MARK: Private Things
extension DataManager {
    private func dictionary(ofReminderState reminderState: ReminderState) -> [String: Bool]? {
        let key = TodoKeys.isCompleted.rawValue
        
        switch reminderState {
        case .completed:
            return [key: true]
        case .notCompleted:
            return [key: false]
        default:
            return nil
        }
    }
    
    private func converted(_ keyedValues: [TodoKeys: Any]) -> [String: Any] {
        var dictionary: [String: Any] = [:]
        for (key, value) in keyedValues {
            dictionary[key.rawValue] = value
        }
        
        return dictionary
    }
    
    private enum UserDefaultsKeys: String {
        case isNotFirstLaunch = "isNotFirstLaunch"
    }
}
