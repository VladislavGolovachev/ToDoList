//
//  TodoManager.swift
//  ToDoList
//
//  Created by Владислав Головачев on 07.09.2024.
//

import Foundation
import CoreData

protocol TodoManagerProtocol: CoreDataStorageManager {
    func count(ofObjectsWithKeyedValues: [String: Any]?) throws -> Int
}

//MARK: CoreDataStorageManager
final class TodoManager: TodoManagerProtocol {
    typealias KeyType = Int
    typealias ObjectType = TodoEntity
    
    private let storage = DummyApiStorage()
    
    func fetch(for index: Int, amongObjectsWithKeyedValues keyedValues: [String : Any]?) throws -> TodoEntity {
        let todos = try fetchAll(with: keyedValues)
        return todos[index]
    }
    
    func update(for index: Int, 
                amongObjectsWithKeyedValues searchingKeyedValues: [String : Any]?,
                with newKeyedValues: [String : Any]) throws {
        
        try storage.backgroundContext.performAndWait { [weak self] in
            let todo = try self?.fetch(for: index, amongObjectsWithKeyedValues: searchingKeyedValues)
            todo?.setValuesForKeys(newKeyedValues)
            
//            try self?.saveContext()
        }
    }
    
    func persist(with keyedValues: [String: Any]) throws {
        try storage.backgroundContext.performAndWait { [weak self] in
            if let error = self?.storage.loadingError {
                throw error
            }
            
            guard let context = self?.storage.backgroundContext,
                  let entity = NSEntityDescription.entity(forEntityName: "TodoEntity",
                                                          in: context) else {return}
            
            let object = NSManagedObject(entity: entity, insertInto: context)
            object.setValuesForKeys(keyedValues)
            
//            try self?.saveContext()
        }
    }
    
    func delete(for index: Int, amongObjectsWithKeyedValues keyedValues: [String : Any]?) throws {
        try storage.backgroundContext.performAndWait { [weak self] in
            guard let strongSelf = self else {
                throw StorageError.unknown
            }
            
            let todo = try strongSelf.fetch(for: index,
                                            amongObjectsWithKeyedValues: keyedValues)
            strongSelf.storage.backgroundContext.delete(todo)
                
//                try strongSelf.saveContext()
        }
    }
    func count(ofObjectsWithKeyedValues keyedValues: [String: Any]?) throws -> Int {
        let todos = try fetchAll(with: keyedValues)
        
        return todos.count
    }
}

//MARK: Private Functions
extension TodoManager {
    private func fetchAll(with keyedValues: [String: Any]?) throws -> [TodoEntity] {
        var todos: [TodoEntity]?
        try storage.backgroundContext.performAndWait { [weak self] in
            guard let strongSelf = self else {
                throw StorageError.unknown
            }
            if let error = strongSelf.storage.loadingError {
                throw error
            }
            
            let request = strongSelf.request()
            let key = TodoKeys.isCompleted.rawValue
            
            if let value = keyedValues?[key] as? Bool {
                let nsNumber = NSNumber(value: value)
                let predicate = NSPredicate(format: "\(key) == %@", nsNumber)
                request.predicate = predicate
            }
            
            do {
                todos = try strongSelf.storage.backgroundContext.fetch(request)
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
        let sortDescriptor = NSSortDescriptor(key: TodoKeys.isCompleted.rawValue,
                                              ascending: true)
        let sortDescriptor1 = NSSortDescriptor(key: TodoKeys.date.rawValue,
                                               ascending: false)
        let sortDescriptor2 = NSSortDescriptor(key: TodoKeys.modificationDate.rawValue,
                                               ascending: false)
        
        let request = TodoEntity.fetchRequest()
        request.sortDescriptors = [sortDescriptor, sortDescriptor1, sortDescriptor2]
        
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
