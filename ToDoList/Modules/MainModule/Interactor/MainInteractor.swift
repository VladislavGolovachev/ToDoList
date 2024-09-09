//
//  MainInteractor.swift
//  ToDoList
//
//  Created by Владислав Головачев on 03.09.2024.
//

import Foundation

protocol MainInteractorOutputProtocol: AnyObject {
    func errorCaused(message: String)
}

protocol MainInteractorInputProtocol: AnyObject {
    func loadInitialReminders()
}

//MARK: MainInteractor
final class MainInteractor {
    var serialQueue = DispatchQueue(label: "serialqueue-interactor-vladislavgolovachev", 
                                    qos: .utility)
    
    weak var presenter: MainInteractorOutputProtocol?
    lazy var dataManager: DataManagerProtocol = DataManager() // needs to alloc from queue, so the context would be private
    let networkManager = NetworkManager()
    
    
}

//MARK: MainInteractorInputProtocol
extension MainInteractor: MainInteractorInputProtocol {
    
    
    func loadInitialReminders() {
        if !dataManager.isFirstLaunch {
            return
        }
        
        networkManager.getTodos { [weak self] result in
            switch result {
            case .success(let todos):
                print("success")
                do {
                    try self?.dataManager.saveTodos(todos, date: Date.now)
                } catch let catchedError {
                    if let error = catchedError as? StorageError {
                        self?.presenter?.errorCaused(message: error.rawValue)
                    }
                }
                
            case .failure(let error):
                print("failure")
                self?.presenter?.errorCaused(message: error.rawValue)
            }
        }
    }
}
