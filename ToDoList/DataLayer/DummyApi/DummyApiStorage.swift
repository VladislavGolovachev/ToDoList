//
//  DummyApiStorage.swift
//  ToDoList
//
//  Created by Владислав Головачев on 07.09.2024.
//

import Foundation
import CoreData

final class DummyApiStorage: CoreDataStorage {
    private var _loadingError: StorageError?
    var loadingError: StorageError? {
        return _loadingError
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DummyApiDataModel")
        container.loadPersistentStores { [weak self] _, error in
            if let error {
                self?._loadingError = .unableToLoadData
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
