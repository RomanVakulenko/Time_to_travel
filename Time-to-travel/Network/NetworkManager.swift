//
//  NetworkManager.swift
//  Time-to-travel
//
//  Created by Roman Vakulenko on 30.08.2023.
//

import Foundation
import UIKit

protocol NetworkManagerProtocol: AnyObject {
    func fetchData(ticketsOptions: String, completion: @escaping (Data) -> Void)
}


final class NetworkManager {

    enum RequestErrors: String, Error {
        case noData
        case noToken
        case unableToCreateRequest
    }

    // MARK: - Private properties
    private let decoder = JSONDecoder()

    // MARK: - Private methods
    private func createRequest(tickets: String) throws -> URLRequest {

        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = "api.travelpayouts.com"
        urlComponents.path = tickets
        urlComponents.queryItems = [
            URLQueryItem(name: "currency", value: "rub"),
            URLQueryItem(name: "period_type", value: "year"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "limit", value: "30"),
            URLQueryItem(name: "show_to_affiliates", value: "false"),
            URLQueryItem(name: "token", value: Singleton.sharedInstance.token),
        ]
        guard let url = urlComponents.url else { throw RequestErrors.unableToCreateRequest }

        return URLRequest(url: url)
    }


    private func parseJSON(withData data: Data) -> TicketForUI? {
        do {
            let ticketsDataForPeriod = try decoder.decode(TicketsDataForPeriod.self, from: data) //декодируем JSON в structData
            guard let ticketForUI = TicketForUI(ticketData: ticketsDataForPeriod.data) else { //cоздаем из structData модельUI
                assertionFailure("не удалось создать ticketForUI")
                return nil
            }
            return ticketForUI
        } catch let error {
            print(error.localizedDescription)
        }
        return nil
    }
}

// MARK: - NetworkManagerProtocol
extension NetworkManager: NetworkManagerProtocol {

    func fetchData(ticketsOptions: String, completion: @escaping (Data) -> Void) {
        do {
            let urlRequest = try createRequest(tickets: ticketsOptions)
            URLSession.shared.dataTask(with: urlRequest) { data, _, _ in
                guard let data else { return }
                completion(data)
                let tickets = self.parseJSON(withData: data)
                print("\n-----------\n")
                print(tickets)

            }.resume()
        
        } catch RequestErrors.noData {
            print(RequestErrors.noData.rawValue)
        } catch RequestErrors.noToken {
            print(RequestErrors.noToken.rawValue)
        } catch RequestErrors.unableToCreateRequest {
            print(RequestErrors.unableToCreateRequest.rawValue)
        } catch {
            print( "что-то неизвестное")
        }
    }
}


