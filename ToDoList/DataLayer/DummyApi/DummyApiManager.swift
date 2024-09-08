//
//  DummyApiManager.swift
//  ToDoList
//
//  Created by Владислав Головачев on 07.09.2024.
//

import Foundation
import CoreData

final class DummyApiManager<ObjectType: NSManagedObject, KeyType>: DummyApiStorage,
                                                                   CoreDataStorageManager {
    func fetch(for key: KeyType) -> ObjectType {
        return NSManagedObject() as! ObjectType
    }
    
    func update(for key: KeyType, with object: ObjectType) {
        
    }
    
    func delete(for key: KeyType) {
        
    }
}
