//
//  NetworkManager.swift
//  Time-to-travel
//
//  Created by Roman Vakulenko on 30.08.2023.
//

import Foundation
import UIKit

typealias NetworkManagerCompetion = (Result<[TicketData], NetWorkManagerErrors>) -> Void //TicketData - это struct билета

protocol NetworkManagerProtocol: AnyObject {
    func getTickets(completion: @escaping NetworkManagerCompetion)
}

final class NetworkManager { // только скачивает и декодирует JSON в struct

    // MARK: - enum
    enum URLConstants {
        static let path = "/v2/prices/latest"
    }

    // MARK: - Private properties
    private let networkRouter: NetworkRouter
    private let mapper: Mapper

    // MARK: - Init
    init(networkRouter: NetworkRouter, mapper: Mapper) {
        self.networkRouter = networkRouter
        self.mapper = mapper
    }

    // MARK: - Private methods
    private func createRequest(withPath path: String) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = "api.travelpayouts.com"
        urlComponents.path = path
        urlComponents.queryItems = [
            URLQueryItem(name: "currency", value: "rub"),
            URLQueryItem(name: "period_type", value: "year"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "limit", value: "30"),
            URLQueryItem(name: "show_to_affiliates", value: "false"),
            URLQueryItem(name: "token", value: Singleton1.token),
        ]
        guard let url = urlComponents.url else { return nil }
        return URLRequest(url: url)
    }


    // MARK: - private method transforms TicketForUI -> [TicketForUI]
//    private func makeTicketsForUI(parsedTickets: [TicketData]) -> [TicketForUI] { //решить где размещать этот метод
//        parsedTickets.compactMap {
//            guard let departureDate = DateManager.createStringFromDate($0.departDate, stringFormat: "yyyy-MM-dd HH:mm:ss ZZZZ zzz"), //??
//                  let arrivalDate = DateManager.createStringFromDate($0.returnDate, stringFormat: "yyyy-MM-dd HH:mm:ss ZZZZ zzz")
//            else { return nil }
//
//            let ticket = TicketForUI(
//                city1: "\($0.origin)",
//                city2: "\($0.destination)",
//                departureDateString: departureDate,
//                arrivalDateString: arrivalDate,
//                price: $0.value
//            )
//            return ticket
//        }
//    }
}

// MARK: - NetworkManagerProtocol
extension NetworkManager: NetworkManagerProtocol {

    func getTickets(completion: @escaping NetworkManagerCompetion) {
        guard let request = createRequest(withPath: URLConstants.path) else {
            DispatchQueue.main.async {
                completion(.failure(NetWorkManagerErrors.networkRouterError(error: .unableToCreateRequest)))
            }
            return
        }

        networkRouter.request(request) { [weak self] result in //почему тут нужно послаблять? где захват?
            switch result {
            case(.success(let data)):

                self?.mapper.decode(from: data, toTicketStruct: TicketsDecoded.self, completion: { result in
                    switch result {
                    case .success(let decodedTickets):
                       let decodedTicketsArr = decodedTickets.data
                        completion(.success(decodedTicketsArr))
                    case .failure(let error):
                        completion(.failure(.mapperError(error: .failParsed(reason: "can not parse/decode data, because of \(error)"))))
                    }
                })

            case .failure(let error):
                completion(.failure(.networkRouterError(error: error)))
            }

        }
    }

}
