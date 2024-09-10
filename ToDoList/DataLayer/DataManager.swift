//
//  DataManager.swift
//  ToDoList
//
//  Created by Владислав Головачев on 07.09.2024.
//

import Foundation

protocol DataManagerProtocol {
    var isFirstLaunch: Bool {get}
    
    func createTodo(with keyedValues: [TodoKeys: Any]) throws
    func fetchTodo(for index: Int, amongReminders: ReminderState) throws -> TodoEntity
    func updateTodo(for index: Int, amongReminders: ReminderState,
                    with keyedValues: [TodoKeys: Any]) throws
    func deleteTodo(for index: Int, amongReminders: ReminderState) throws
    func getTodosCount(ofReminders: ReminderState) throws -> Int
    func saveTodos(_: [DummyTodo], date: Date) throws
}

final class DataManager: DataManagerProtocol {
    private let todoManager = TodoManager()
    
    var isFirstLaunch: Bool {
        return true
        let key = UserDefaultsKeys.isNotFirstLaunch.rawValue
        let isNotFirstLaunch = UserDefaults.standard.bool(forKey: key)
        UserDefaults.standard.setValue(true, forKey: key)
        
        return !isNotFirstLaunch
    }
    
    func createTodo(with keyedValues: [TodoKeys: Any]) throws {
        try todoManager.persist(with: converted(keyedValues))
    }
    
    func fetchTodo(for index: Int, amongReminders state: ReminderState) throws -> TodoEntity {
        let dict = dictionaryFor(state)
        let todo = try todoManager.fetch(for: index, amongObjectsWithKeyedValues: dict)
        
        return todo
    }
    
    func updateTodo(for index: Int, amongReminders state: ReminderState, 
                    with keyedValues: [TodoKeys: Any]) throws {
        let dict = dictionaryFor(state)
        try todoManager.update(for: index,
                               amongObjectsWithKeyedValues: dict,
                               with: converted(keyedValues))
    }
    
    func deleteTodo(for index: Int, amongReminders state: ReminderState) throws {
        let dict = dictionaryFor(state)
        try todoManager.delete(for: index, amongObjectsWithKeyedValues: dict)
    }
    
    func getTodosCount(ofReminders state: ReminderState) throws -> Int {
        let dict = dictionaryFor(state)
        let count = try todoManager.count(ofObjectsWithKeyedValues: dict)
        
        return count
    }
    
    func saveTodos(_ todos: [DummyTodo], date: Date) throws {
        
        for (i, todo) in todos.enumerated() {
            let milliSecond = Double(i) / 1000
            let keyedValues: [TodoKeys: Any] = [
                .reminder:      todo.reminder,
                .isCompleted:   todo.isCompleted,
                .creationDate:  date + milliSecond
            ]
            try todoManager.persist(with: converted(keyedValues))
        }
    }
}

//MARK: Private Things
extension DataManager {
    private func dictionaryFor(_ reminderState: ReminderState) -> [String: Bool]? {
        var key = TodoKeys.isCompleted.rawValue
        
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
