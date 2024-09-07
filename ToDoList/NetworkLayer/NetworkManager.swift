//
//  NetworkManager.swift
//  ToDoList
//
//  Created by Владислав Головачев on 07.09.2024.
//

import Foundation

protocol NetworkManagerProtocol {
    func getTodos(completion: @escaping (Result<TodosResponse, NetworkError>) -> Void)
}

//MARK: NetworkManagerProtocol
struct NetworkManager: NetworkManagerProtocol {
    private let router = NetworkRouter<DummyApiEndPoint>()
    
    func getTodos(completion: @escaping (Result<TodosResponse, NetworkError>) -> Void) {
        router.request(.todos) { data, response, error in
            if error != nil {
                completion(.failure(.networkConnection))
                return
            }
            if let response, let possibleError = handleURLResponse(response) {
                completion(.failure(possibleError))
                return
            }
            guard let data else {
                completion(.failure(.missingData))
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(TodosResponse.self, from: data)
                completion(.success(apiResponse))
            } catch {
                completion(.failure(.unableToDecode))
            }
        }
    }
}

//MARK: Private Functions
extension NetworkManager {
    private func handleURLResponse(_ response: URLResponse) -> NetworkError? {
        guard let httpResponse = response as? HTTPURLResponse else {
            return .unknown
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return nil
        case 400...499:
            return .clientProblem
        case 500...599:
            return .serverProblem
        case 600:
            return .outdatedRequest
        default:
            return .unknown
        }
    }
}
