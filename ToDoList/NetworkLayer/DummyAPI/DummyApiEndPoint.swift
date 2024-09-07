//
//  DummyApiEndPoint.swift
//  ToDoList
//
//  Created by Владислав Головачев on 07.09.2024.
//

import Foundation

enum DummyApiEndPoint {
    case todos
}

extension DummyApiEndPoint: EndPointType {
    var baseUrl: URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "dummyjson.com"
        
        return urlComponents.url
    }
    var path: String {
        return "todos"
    }
    var queryItems: [URLQueryItem] {
        return [URLQueryItem]()
    }
    var httpMethod: HTTPMethod {
        return .get
    }
}
