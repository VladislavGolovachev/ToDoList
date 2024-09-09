//
//  MainInteractor.swift
//  ToDoList
//
//  Created by Владислав Головачев on 03.09.2024.
//

import Foundation

protocol MainInteractorOutputProtocol: AnyObject {
    func errorCaused(message: String)
    func reloadView()
}

protocol MainInteractorInputProtocol: AnyObject {
    func loadInitialReminders()
    
    func todoProperty(for index: Int, property: TodoKeys) -> Any?
    func remindersCount(areForCompleted areCompleted: Bool?) -> Int
}

//MARK: MainInteractor
final class MainInteractor {
    var serialQueue = DispatchQueue(label: "serialqueue-interactor-vladislavgolovachev",
                                    qos: .utility)
    
    weak var presenter: MainInteractorOutputProtocol?
    // needs to alloc from queue, so the context would be private
    lazy var dataManager: DataManagerProtocol = DataManager()
    let networkManager = NetworkManager()
}

//MARK: MainInteractorInputProtocol
extension MainInteractor: MainInteractorInputProtocol {
    func remindersCount(areForCompleted areCompleted: Bool?) -> Int {
        var count = 0
        do {
            count = try dataManager.getTodosCount(areForCompleted: areCompleted)
        } catch {
            handleStorageError(error)
            return 0
        }
        
        return count
    }
    
    func todoProperty(for index: Int, property: TodoKeys) -> Any? {
        var todo: TodoEntity
        do {
            todo = try dataManager.fetchTodo(for: index)
        } catch {
            handleStorageError(error)
            return nil
        }
        
        switch property {
        case .reminder:
            return todo.reminder
        case .notes:
            return todo.notes
        case .isCompleted:
            return todo.isCompleted
        case .date:
            return todo.date
        default:
            return nil
        }
    }
    
    func loadInitialReminders() {
        if !dataManager.isFirstLaunch {
            return
        }
        
        networkManager.getTodos { [weak self] result in
            switch result {
            case .success(let todos):
                do {
                    try self?.dataManager.saveTodos(todos, date: Date.now)
                } catch let catchedError {
                    if let error = catchedError as? StorageError {
                        self?.presenter?.errorCaused(message: error.rawValue)
                    }
                }
                self?.presenter?.reloadView()
            case .failure(let error):
                self?.presenter?.errorCaused(message: error.rawValue)
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
}
