//
//  TodoStorage.swift
//  ToDoList
//
//  Created by Владислав Головачев on 07.09.2024.
//

import Foundation
import CoreData

final class TodoManager<ObjectType: Todo, KeyType>: DummyApiStorage,
                                                    CoreDataStorageManager {
    func fetch(for key: KeyType) -> Todo {
        <#code#>
    }
    
    func update(for key: KeyType, with object: Todo) {
        <#code#>
    }
    
    func delete(for key: KeyType) {
        <#code#>
    }
}
