//
//  DataManager.swift
//  ToDoList
//
//  Created by Владислав Головачев on 07.09.2024.
//

import Foundation

protocol DataManagerProtocol {
    
}

final class DataManager: DataManagerProtocol {
    private let todoManager = DummyApiManager<Todo, Int>()
}
