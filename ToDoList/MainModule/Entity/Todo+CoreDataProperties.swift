//
//  Todo+CoreDataProperties.swift
//  ToDoList
//
//  Created by Владислав Головачев on 08.09.2024.
//
//

import Foundation
import CoreData


extension Todo {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Todo> {
        return NSFetchRequest<Todo>(entityName: "Todo")
    }

    @NSManaged public var reminder: String
    @NSManaged public var notes: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var date: Date
    @NSManaged public var id: Int32
}

extension Todo: Identifiable {

}
