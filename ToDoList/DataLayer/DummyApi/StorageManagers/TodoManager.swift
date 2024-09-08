//
//  TodoManager.swift
//  ToDoList
//
//  Created by Владислав Головачев on 07.09.2024.
//

import Foundation
import CoreData

final class TodoManager: CoreDataStorageManager {
    typealias KeyType = Int
    typealias ObjectType = TodoEntity
    
    private let storage = DummyApiStorage()
    
    func fetch(for index: Int) throws -> TodoEntity {
        let todos = try fetchAll()
        return todos[index]
    }
    
    func persist(with keyedValues: [String: Any]) throws {
        if let error = storage.loadingError {
            throw error
        }
        
        try storage.backgroundContext.performAndWait { [weak self] in
            guard let notOptionalSelf = self,
                  let entity = NSEntityDescription.entity(forEntityName: "TodoEntity",
                                                          in: notOptionalSelf.storage.backgroundContext) else {return}
            entity.setValuesForKeys(keyedValues)
            
            try self?.saveContext()
        }
    }
    
    func update(for index: Int, with keyedValues: [String: Any]) throws {
        try storage.backgroundContext.performAndWait { [weak self] in
            let todo = try self?.fetch(for: index)
            todo?.setValuesForKeys(keyedValues)
            
            try self?.saveContext()
        }
    }
    
    func delete(for index: Int) throws {
        try storage.backgroundContext.performAndWait { [weak self] in
            if let todo = try self?.fetch(for: index) {
                self?.storage.backgroundContext.delete(todo)
                
                try self?.saveContext()
            }
        }
    }
    
    func count() throws -> Int {
        let todos = try fetchAll()
        return todos.count
    }
}

extension TodoManager {
    private func fetchAll() throws -> [TodoEntity] {
        if let error = storage.loadingError {
            throw error
        }
        
        let request = request()
        var todos: [TodoEntity]?
        try storage.backgroundContext.performAndWait { [weak self] in
            do {
                todos = try self?.storage.backgroundContext.fetch(request)
            } catch {
                throw StorageError.fetchingFailed
            }
        }
        
        if let todos {
            return todos
        }
        throw StorageError.missingObject
    }
    
    private func request() -> NSFetchRequest<TodoEntity> {
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        let request = TodoEntity.fetchRequest()
        request.sortDescriptors = [sortDescriptor]
        
        return request
    }
    
    private func saveContext() throws {
        try storage.backgroundContext.performAndWait { [weak self] in
            do {
                try self?.storage.backgroundContext.save()
            } catch {
                throw StorageError.unableToSaveData
            }
        }
    }
}

extension TodoManager {
    enum TodoKeys: String{
        case reminder = "reminder"
        case notes = "notes"
        case isCompleted = "isCompleted"
        case date = "date"
    }
}
