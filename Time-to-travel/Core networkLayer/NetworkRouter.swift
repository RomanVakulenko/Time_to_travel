//
//  NetworkRouter.swift
//  Time-to-travel
//
//  Created by Roman Vakulenko on 22.09.2023.
//

import Foundation

typealias NetworkRouterCompletion = (Result<Data, RouterErrors>) -> Void

protocol NetworkProtocol {
    func request(_ urlRequest: URLRequest, completion: @escaping NetworkRouterCompletion)
}


final class NetworkRouter {

}


// MARK: - Extensions
extension NetworkRouter: NetworkProtocol {

    func request(_ urlRequest: URLRequest, completion: @escaping NetworkRouterCompletion) {
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard error == nil else {
                DispatchQueue.main.async { completion(.failure(RouterErrors.unableToCreateRequest)) }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(RouterErrors.noData(reason: "нет данных"))) }
                return
            }
            DispatchQueue.main.async { completion(.success(data)) }
        }
    }


}
