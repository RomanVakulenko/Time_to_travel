//
//  NetworkManager.swift
//  Time-to-travel
//
//  Created by Roman Vakulenko on 30.08.2023.
//

import Foundation
import UIKit

protocol NetworkManagerProtocol: AnyObject {
    func fetchData(ticketsOptions: String, completion: @escaping ([TicketForUI]) -> Void) //async throws
}

final class NetworkManager {

    // MARK: - Private properties
    private let decoder = JSONDecoder()

    // MARK: - Private methods
    private func createRequest(withOptions options: String) throws -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = "api.travelpayouts.com"
        urlComponents.path = options
        urlComponents.queryItems = [
            URLQueryItem(name: "currency", value: "rub"),
            URLQueryItem(name: "period_type", value: "year"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "limit", value: "30"),
            URLQueryItem(name: "show_to_affiliates", value: "false"),
            URLQueryItem(name: "token", value: Singleton1.token),
        ]
        guard let url = urlComponents.url else { throw RouterErrors.unableToCreateRequest }
        return URLRequest(url: url)
    }
//http://api.travelpayouts.com/v2/prices/latest?currency=rub&period_type=year&page=1&limit=30&show_to_affiliates=true&sorting=price&token=8adf47e8d901e2a6f5b58897510f9cdb


    private func parseJSON(withData data: Data) -> [TicketForUI]? {
//        let dataFromTextJsonToDisplayMultipleFlights = textJsonToDisplayMultiple.data(using: .utf8) //чтобы провить показ нескольких билетов (иной раз запрос выдает по 1 билету)
        do {
            let parsedTicketsData = try decoder.decode(TicketsDataForPeriod.self, from: data) // JSON -> TicketsDataForPeriod
            let ticketsArrForUI = makeArrOfTicketsForUI(dataTickets: parsedTicketsData.data) // data: [TicketData] -> [TicketForUI]
            return ticketsArrForUI
        } catch let error {
            print(error.localizedDescription)
        }
        return nil
    }


    // MARK: - private method transforms TicketForUI -> [TicketForUI]
    private func makeArrOfTicketsForUI(dataTickets: [TicketData]) -> [TicketForUI] { //ГДЕ ЛУЧШЕ РАЗМЕЩАТЬ ЭТОТ МЕТОД??
        var resultArray: [TicketForUI] = []

        for number in 0..<dataTickets.count {
            let newTicket = TicketForUI(
                city1: "\(dataTickets[number].origin)",
                city2: "\(dataTickets[number].destination)",
                departureDateString: dataTickets[number].departDate,
                arrivalDateString: dataTickets[number].returnDate,
                price: dataTickets[number].value
            )
            resultArray.append(newTicket)
        }
        return resultArray
    }
}

// MARK: - NetworkManagerProtocol
extension NetworkManager: NetworkManagerProtocol {

    func fetchData(ticketsOptions: String, completion: @escaping ([TicketForUI]) -> Void) {
        do {
            let urlRequest = try createRequest(withOptions: ticketsOptions)
            let task = URLSession.shared.dataTask(with: urlRequest) { data, _, _ in
                guard let data else { return }
                if let tickets = self.parseJSON(withData: data) {
                    completion(tickets)
                }
            }
            task.resume()

        } catch RouterErrors.noData {
            print(RouterErrors.noData.rawValue)
        } catch RouterErrors.noToken {
            print(RouterErrors.noToken.rawValue)
        } catch RouterErrors.unableToCreateRequest {
            print(RouterErrors.unableToCreateRequest.rawValue)
        } catch {
            print( "что-то неизвестное")
        }
    }

//вариант с async
//    func fetchData(ticketsOptions: String, completion: @escaping ([TicketForUI]) -> Void) async throws {
//        do {
//            let urlRequest = try createRequest(withOptions: ticketsOptions)
//            let (data, _) = try await URLSession.shared.data(for: urlRequest)
//            if let tickets = self.parseJSON(withData: data) {
//                completion(tickets)
//            }
//        } catch RequestErrors.noData {
//            print(RequestErrors.noData.rawValue)
//        } catch RequestErrors.noToken {
//            print(RequestErrors.noToken.rawValue)
//        } catch RequestErrors.unableToCreateRequest {
//            print(RequestErrors.unableToCreateRequest.rawValue)
//        } catch RequestErrors.unableToCreateURL{
//            print(RequestErrors.unableToCreateRequest.rawValue)
//        } catch {
//            print( "что-то неизвестное")
//        }
//    }


}

//let textJsonToDisplayMultiple = """
//{
//    "currency": "rub",
//    "error": "",
//    "data": [
//        {
//            "depart_date": "2023-09-13",
//            "origin": "MOW",
//            "destination": "EKV",
//            "gate": "Azimuth",
//            "return_date": "2023-09-15",
//            "found_at": "2023-09-03T08:41:07",
//            "trip_class": 0,
//            "value": 3230,
//            "number_of_changes": 0,
//            "duration": 165,
//            "distance": 600,
//            "show_to_affiliates": true,
//            "actual": true
//        },
//        {
//            "depart_date": "2023-08-13",
//            "origin": "MOW",
//            "destination": "SSV",
//            "gate": "Azimuth",
//            "return_date": "2023-01-15",
//            "found_at": "2023-09-03T08:41:07",
//            "trip_class": 0,
//            "value": 1430,
//            "number_of_changes": 0,
//            "duration": 165,
//            "distance": 600,
//            "show_to_affiliates": true,
//            "actual": true
//        }
//    ],
//    "success": true
//}
//"""