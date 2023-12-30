//
//  NetworkManager.swift
//  Time-to-travel
//
//  Created by Roman Vakulenko on 30.08.2023.
//

import Foundation
import UIKit

// вариант с async await
protocol NetworkManagerProtocol: AnyObject {
    func getDecodedModel<T: Decodable> (using url: URL, model: T.Type) async throws -> T
}

final class NetworkManager { // скачивает и декодирует JSON в struct

    // MARK: - Private properties
    private let networkRouter: NetworkRouterProtocol
    private let mapper: MapperProtocol

    // MARK: - Init
    init(networkRouter: NetworkRouterProtocol, mapper: MapperProtocol) {
        self.networkRouter = networkRouter
        self.mapper = mapper
    }
}

// MARK: - NetworkManagerProtocol
extension NetworkManager: NetworkManagerProtocol {

    func getDecodedModel<T: Decodable> (using url: URL, model: T.Type) async throws -> T {
        do {
            let data = try await networkRouter.requestDataWith(url)
            let decodedModel = try mapper.decode(from: data, toStruct: model)
            return decodedModel
        } catch let error as RouterErrors {
            throw NetWorkManagerErrors.networkRouterError(error: error)
        } catch let error as MapperError {
            throw NetWorkManagerErrors.mapperError(error: error)
        }
    }
}

// Вариант с GCD + result
// typealias NetworkManagerCompletion = (Result<[TicketData], NetWorkManagerErrors>) -> Void //TicketData - это struct билета
//
// protocol NetworkManagerProtocol: AnyObject {
//    func getTicketsData(completion: @escaping NetworkManagerCompletion)
// }
//
// final class NetworkManager { // только скачивает и декодирует JSON в struct
//
//    // MARK: - Private properties
//    private let networkRouter: NetworkRouterProtocol
//    private let mapper: MapperProtocol
//
//    // MARK: - Init
//    init(networkRouter: NetworkRouterProtocol, mapper: MapperProtocol) {
//        self.networkRouter = networkRouter
//        self.mapper = mapper
//    }
//
//    // MARK: - Private methods
//    private func createRequest() -> URLRequest? {
//        let endPoint = EndPont.shared.urlFor(variant: .pricesForLatest) //создаем нужный URL
//
//        guard let url = endPoint else {
//            assertionFailure("не удалось создать URL")
//            return nil
//        }
//        return URLRequest(url: url)
//    }
// }
//
// MARK: - NetworkManagerProtocol
// extension NetworkManager: NetworkManagerProtocol {
//
//    func getTicketsData(completion: @escaping NetworkManagerCompletion) {
//        guard let urlRequest = createRequest() else {
//            DispatchQueue.main.async {
//                completion(.failure(NetWorkManagerErrors.networkRouterError(error: .unableToCreateRequest)))
//            }
//            return
//        }
//
//        networkRouter.requestDataWith(urlRequest) { [weak self] result in // почему тут нужно послаблять? где захват?
//            switch result {
//            case .success(let data):
//                self?.mapper.decode(from: data, toStruct: TicketsDecoded.self, completion: { result in
//
//                    switch result {
//                    case .success(let decodedTickets):
//                       let decodedTicketsArr = decodedTickets.data
//                        completion(.success(decodedTicketsArr))
//
//                    case .failure(let error):
//                        completion(.failure(.mapperError(error: .failParsed(reason: error.localizedDescription))))
//                    }
//                })
//
//            case .failure(let error):
//                completion(.failure(.networkRouterError(error: error)))
//            }
//        }
//
//    }
//
// }
