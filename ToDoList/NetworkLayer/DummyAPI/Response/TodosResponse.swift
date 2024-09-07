//
//  TodosResponse.swift
//  ToDoList
//
//  Created by Владислав Головачев on 07.09.2024.
//

import Foundation

struct TodosResponse: Decodable {
    let todos: [Todo]
}

struct Todo: Decodable {
    let reminder: String
    let isCompleted: Bool
    
    private enum CodingKeys: String, CodingKey {
        case reminder = "todo"
        case isCompleted = "completed"
    }
}
