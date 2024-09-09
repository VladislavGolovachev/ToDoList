//
//  MainInteractor.swift
//  ToDoList
//
//  Created by Владислав Головачев on 03.09.2024.
//

import Foundation

protocol MainInteractorOutputProtocol: AnyObject {
    
}

protocol MainInteractorInputProtocol: AnyObject {
    
}

final class MainInteractor: MainInteractorInputProtocol {
    var serialQueue = DispatchQueue(label: "serialqueue-interactor-vladislavgolovachev", 
                                    qos: .utility)
    
    weak var presenter: MainInteractorOutputProtocol?
    lazy var dataManager: DataManagerProtocol = DataManager() // needs to alloc from queue, so the context would be private
}
