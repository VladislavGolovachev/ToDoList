//
//  NetworkError.swift
//  ToDoList
//
//  Created by Владислав Головачев on 07.09.2024.
//

import Foundation

enum NetworkError: String, Error {
    case networkConnection  = "Check your network connection"
    case outdatedRequest    = "Request has been outdated"
    case missingURL         = "Incorrect URL"
    case clientProblem      = "Error caused by client's problem"
    case serverProblem      = "Error caused by server's problem"
    case missingData        = "Network response returned without data"
    case unableToDecode     = "Data cannot be decoded"
    case unknown            = "An unknown error was caused"
}
