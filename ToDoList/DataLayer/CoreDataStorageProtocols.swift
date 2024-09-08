//
//  CoreDataStorage.swift
//  ToDoList
//
//  Created by Владислав Головачев on 08.09.2024.
//

import Foundation
import CoreData

protocol CoreDataStorage {
    var persistentContainer: NSPersistentContainer {get}
    var backgroundContext: NSManagedObjectContext {get}
}

protocol CoreDataStorageManager {
    associatedtype ObjectType = NSManagedObject
    associatedtype KeyType
    
    func fetch(for key: KeyType) -> ObjectType
    func update(for key: KeyType, with object: ObjectType)
    func delete(for key: KeyType)
}
