//
//  CoreDataStorage.swift
//  ToDoList
//
//  Created by Владислав Головачев on 08.09.2024.
//

import Foundation
import CoreData

protocol CoreDataStorage {
    var loadingError: StorageError? {get}
    var persistentContainer: NSPersistentContainer {get}
    var backgroundContext: NSManagedObjectContext {get}
}

protocol CoreDataStorageManager {
    associatedtype ObjectType: NSManagedObject
    associatedtype KeyType
    
    func fetch(amongObjectsWithKeyedValues: [String: Any]?) throws -> [ObjectType]
    func persist(with keyedValues: [String: Any]) throws
    func update(for: KeyType, amongObjectsWithKeyedValues: [String: Any]?,
                with keyedValues: [String: Any]) throws
    func delete(for: KeyType, amongObjectsWithKeyedValues: [String: Any]?) throws
}
