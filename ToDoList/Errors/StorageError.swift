//
//  StorageError.swift
//  ToDoList
//
//  Created by Владислав Головачев on 08.09.2024.
//

import Foundation

enum StorageError: String, Error {
    case unabletoLoadData = "Unable to load persistent stores"
}
