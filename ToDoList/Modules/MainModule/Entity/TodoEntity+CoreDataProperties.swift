//
//  TodoEntity+CoreDataProperties.swift
//  ToDoList
//
//  Created by Владислав Головачев on 08.09.2024.
//
//

import Foundation
import CoreData


extension TodoEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoEntity> {
        return NSFetchRequest<TodoEntity>(entityName: "TodoEntity")
    }

    @NSManaged public var date: Date?
    @NSManaged public var creationDate: Date
    @NSManaged public var isCompleted: Bool
    @NSManaged public var notes: String?
    @NSManaged public var reminder: String?

}

extension TodoEntity: Identifiable {

}
