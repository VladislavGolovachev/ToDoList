//
//  DataManager.swift
//  ToDoList
//
//  Created by Владислав Головачев on 07.09.2024.
//

import Foundation

protocol DataManagerProtocol {
    func fetchTodo(for index: Int) throws -> TodoEntity
    func updateTodo(for index: Int, with keyedValues: [TodoKeys: Any]) throws
    func deleteTodo(for index: Int) throws
    func getTodosCount() throws -> Int
    
    func saveTodos(_: [DummyTodo], date: Date) throws
    var isFirstLaunch: Bool {get}
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
    
    func fetchTodo(for index: Int) throws -> TodoEntity {
        let todo = try todoManager.fetch(for: index)
        return todo
    }
    
    func updateTodo(for index: Int, with keyedValues: [TodoKeys: Any]) throws {
        try todoManager.update(for: index,
                               with: converted(keyedValues))
    }
    
    func deleteTodo(for index: Int) throws {
        try todoManager.delete(for: index)
    }
    
    func getTodosCount() throws -> Int {
        let count = try todoManager.count()
        
        return count
    }
    
    func saveTodos(_ todos: [DummyTodo], date: Date) throws {
        for todo in todos {
            print(todo.reminder, todo.isCompleted)
            let keyedValues: [TodoKeys: Any] = [
                .reminder:      todo.reminder,
                .isCompleted:   todo.isCompleted,
                .date:          date
            ]
            try todoManager.persist(with: converted(keyedValues))
        }
    }
}

//MARK: Private Things
extension DataManager {
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
