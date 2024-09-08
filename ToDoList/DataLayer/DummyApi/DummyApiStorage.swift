//
//  DummyApiStorage.swift
//  ToDoList
//
//  Created by Владислав Головачев on 07.09.2024.
//

import Foundation
import CoreData

class DummyApiStorage: CoreDataStorage {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DummyApiDataModel")
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        
        return container
    }()
    lazy var backgroundContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        context.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        
        return context
    }()
}
