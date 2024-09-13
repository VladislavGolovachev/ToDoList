//
//  MainInteractor.swift
//  ToDoList
//
//  Created by Владислав Головачев on 03.09.2024.
//

import Foundation

protocol MainInteractorOutputProtocol: AnyObject {
    func reloadView(with: [Todo])
    func reloadTabs(with counts: [Int])
    func errorCaused(message: String)
}

protocol MainInteractorInputProtocol: AnyObject {
    func loadInitialReminders(completion: @escaping () -> Void)
    func fetchTodos(amongReminders: ReminderState)
    func fetchInitialCounts()
    
    func addNewReminder()
    func updateReminder(for index: Int, amongReminders: ReminderState, with: [TodoKeys: Any], completion: (() -> Void)?)
    func deleteReminder(for index: Int, amongReminders: ReminderState)
}

//MARK: MainInteractor
final class MainInteractor {
    weak var presenter: MainInteractorOutputProtocol?
    // needs to alloc from queue, so the context would be private
    lazy var dataManager: DataManagerProtocol = DataManager()
    let networkManager = NetworkManager()
}

//MARK: MainInteractorInputProtocol
extension MainInteractor: MainInteractorInputProtocol {
    func addNewReminder() {
        let dict: [TodoKeys: Any] = [
            .reminder: MainViewConstants.initialReminderText,
            .isCompleted: false,
            .creationDate: Date.now
        ]
        
        do {
            try dataManager.saveTodo(with: dict)
        } catch {
            handleStorageError(error)
        }
    }
    
    func updateReminder(for index: Int, 
                        amongReminders state: ReminderState,
                        with keyedValues: [TodoKeys: Any],
                        completion: (() -> Void)?) {
        do {
            try dataManager.updateTodo(for: index, amongReminders: state, with: keyedValues)
            completion?()
        } catch {
            handleStorageError(error)
        }
    }
    
    func deleteReminder(for index: Int, amongReminders state: ReminderState) {
        do {
            try dataManager.deleteTodo(for: index, amongReminders: state)
        } catch {
            handleStorageError(error)
        }
    }
    
    func fetchTodos(amongReminders state: ReminderState) {
        do {
            let todoEntities = try dataManager.fetchTodos(amongReminders: state)
            let todos = converted(todoEntities)
            presenter?.reloadView(with: todos)
        } catch {
            handleStorageError(error)
        }
    }
    
    func fetchInitialCounts() {
        do {
            let counts = try dataManager.getTodosCounts()
            presenter?.reloadTabs(with: counts)
        } catch {
            handleStorageError(error)
        }
    }
    
    func loadInitialReminders(completion: @escaping () -> Void) {
        if !dataManager.isFirstLaunch {
            completion()
            return
        }
        
        networkManager.getTodos { [weak self] result in
            guard let strongSelf = self else {return}
            
            switch result {
            case .success(let todos):
                do {
                    let keyedValuesArray = strongSelf.converted(todos)
                    try strongSelf.dataManager.saveTodos(by: keyedValuesArray)
                    
                    completion()
                } catch let catchedError {
                    if let error = catchedError as? StorageError {
                        strongSelf.presenter?.errorCaused(message: error.rawValue)
                    }
                }
            case .failure(let error):
                strongSelf.presenter?.errorCaused(message: error.rawValue)
            }
        }
    }
}

//MARK: Private Functions
extension MainInteractor {
    private func handleStorageError(_ error: Error) {
        if let storageError = error as? StorageError {
            presenter?.errorCaused(message: storageError.rawValue)
        }
    }
    
    private func converted(_ todos: [DummyTodo]) -> [[TodoKeys: Any]] {
        var keyedValuesArray = [[TodoKeys: Any]]()
        let date = Date.now
        
        for (i, todo) in todos.enumerated() {
            let milliSecond = Double(i) / 1000
            let keyedValues: [TodoKeys: Any] = [
                .reminder:      todo.reminder,
                .isCompleted:   todo.isCompleted,
                .creationDate:  date + milliSecond
            ]
            
            keyedValuesArray.append(keyedValues)
        }
        
        return keyedValuesArray
    }
    
    private func converted(_ todoEntities: [TodoEntity]) -> [Todo] {
        var todos = [Todo]()
        for todoEntity in todoEntities {
            let todo = Todo(reminder: todoEntity.reminder,
                            notes: todoEntity.notes,
                            isCompleted: todoEntity.isCompleted,
                            date: todoEntity.date)
            
            todos.append(todo)
        }
        
        return todos
    }
}
