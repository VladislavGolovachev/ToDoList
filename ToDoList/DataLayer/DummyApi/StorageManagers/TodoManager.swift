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
    
    func fetch(amongObjectsWithKeyedValues keyedValues: [String : Any]?) throws -> [TodoEntity] {
        var todos: [TodoEntity]?
        try storage.backgroundContext.performAndWait { [weak self] in
            guard let strongSelf = self else {
                throw StorageError.unknown
            }
            if let error = strongSelf.storage.loadingError {
                throw error
            }
            
            let request = strongSelf.request(isSortNeeded: true, predicateKeyedValues: keyedValues)
            
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
    
    func update(for index: Int, 
                amongObjectsWithKeyedValues searchingKeyedValues: [String : Any]?,
                with newKeyedValues: [String : Any]) throws {
        
        try storage.backgroundContext.performAndWait { [weak self] in
            let todos = try self?.fetch(amongObjectsWithKeyedValues: searchingKeyedValues)

            todos?[index].setValuesForKeys(newKeyedValues)
            
            try self?.saveContext()
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
            
            try self?.saveContext()
        }
    }
    
    func delete(for index: Int, amongObjectsWithKeyedValues keyedValues: [String : Any]?) throws {
        try storage.backgroundContext.performAndWait { [weak self] in
            guard let strongSelf = self else {
                throw StorageError.unknown
            }
            let todos = try strongSelf.fetch(amongObjectsWithKeyedValues: keyedValues)
            
            strongSelf.storage.backgroundContext.delete(todos[index])
                
                try strongSelf.saveContext()
        }
    }
    func count(ofObjectsWithKeyedValues keyedValues: [String: Any]?) throws -> Int {
        var count = 0
        try storage.backgroundContext.performAndWait {
            let request = request(isSortNeeded: false, predicateKeyedValues: keyedValues)
            
            do {
                count = try storage.backgroundContext.count(for: request)
            } catch {
                throw StorageError.fetchingFailed
            }
        }
        
        return count
    }
}

//MARK: Private Functions
extension TodoManager {
    private func request(isSortNeeded: Bool, predicateKeyedValues keyedValues: [String: Any]?) -> NSFetchRequest<TodoEntity> {
        let request = TodoEntity.fetchRequest()
        
        if isSortNeeded {
            let sortDescriptor1 = NSSortDescriptor(key: TodoKeys.isCompleted.rawValue,
                                                   ascending: true)
            let sortDescriptor2 = NSSortDescriptor(key: TodoKeys.creationDate.rawValue,
                                                   ascending: false)
            request.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        }
        
        let key = TodoKeys.isCompleted.rawValue
        if let value = keyedValues?[key] as? Bool {
            let nsNumber = NSNumber(value: value)
            let predicate = NSPredicate(format: "\(key) == %@", nsNumber)
            request.predicate = predicate
        }
        
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
