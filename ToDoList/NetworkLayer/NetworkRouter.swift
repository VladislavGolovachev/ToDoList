//
//  NetworkRouter.swift
//  ToDoList
//
//  Created by Владислав Головачев on 07.09.2024.
//

import Foundation

protocol NetworkRouterProtocol {
    associatedtype EndPoint: EndPointType
    func request(_ route: EndPoint, completion: @escaping (Data?, URLResponse?, Error?) -> Void)
}

final class NetworkRouter<EndPoint: EndPointType>: NetworkRouterProtocol {
    func request(_ route: EndPoint, completion: @escaping (Data?, URLResponse?, Error?) -> Void)  {
        do {
            let urlRequest = try buildRequest(from: route)
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                completion(data, response, error)
            }
            task.resume()
        } catch {
            completion(nil, nil, error)
        }
    }
}

//MARK: Private Functions
extension NetworkRouter {
    private func buildRequest(from route: EndPoint) throws -> URLRequest {
        guard var url = route.baseUrl else {
            throw NetworkError.missingURL
        }
        url.append(path: route.path)
        url.append(queryItems: route.queryItems)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = route.httpMethod.rawValue
        
        return urlRequest
    }
}
