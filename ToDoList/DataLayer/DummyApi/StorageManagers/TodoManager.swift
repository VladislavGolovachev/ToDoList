//
//  TodoManager.swift
//  ToDoList
//
//  Created by Владислав Головачев on 07.09.2024.
//

import Foundation
import CoreData

//MARK: CoreDataStorageManager
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
            guard let context = self?.storage.backgroundContext,
                  let entity = NSEntityDescription.entity(forEntityName: "TodoEntity",
                                                          in: context) else {return}
            
            let object = NSManagedObject(entity: entity, insertInto: context)
            object.setValuesForKeys(keyedValues)
            
//            try self?.saveContext()
        }
    }
    
    func update(for index: Int, with keyedValues: [String: Any]) throws {
        try storage.backgroundContext.performAndWait { [weak self] in
            let todo = try self?.fetch(for: index)
            todo?.setValuesForKeys(keyedValues)
            
//            try self?.saveContext()
        }
    }
    
    func delete(for index: Int) throws {
        try storage.backgroundContext.performAndWait { [weak self] in
            if let todo = try self?.fetch(for: index) {
                self?.storage.backgroundContext.delete(todo)
                
//                try self?.saveContext()
            }
        }
    }
}

//MARK: Additional Public Functions
extension TodoManager {
    func fetch(for index: Int, forCompleted isCompleted: Bool) throws -> TodoEntity {
        let todos = try fetchAll(with: isCompleted)
        return todos[index]
    }
    
    func count(areForCompleted areCompleted: Bool? = nil) throws -> Int {
        let todos = try fetchAll(with: areCompleted)
        return todos.count
    }
}

//MARK: Private Functions
extension TodoManager {
    private func fetchAll(with areCompleted: Bool? = nil) throws -> [TodoEntity] {
        if let error = storage.loadingError {
            throw error
        }
        
        let request = request()
        if let areCompleted {
            let predicate = NSPredicate(format: "isCompleted == %@",
                                        NSNumber(value: areCompleted))
            request.predicate = predicate
        }
        
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
        let sortDescriptor1 = NSSortDescriptor(key: TodoKeys.date.rawValue,
                                               ascending: false)
        let sortDescriptor2 = NSSortDescriptor(key: TodoKeys.creationDate.rawValue,
                                               ascending: false)
        
        let request = TodoEntity.fetchRequest()
        request.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        
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
