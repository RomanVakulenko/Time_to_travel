//
//  DataTransformer.swift
//  Time-to-travel
//
//  Created by Roman Vakulenko on 25.09.2023.
//

import Foundation
// вариант с async await
protocol DataTransformerProtocol {
    func makeTicketsFromData(at url: URL) async throws -> [TicketForUI]
}

final class DataTransformer {

    // MARK: - Private properties
    private let networkManager: NetworkManagerProtocol

    // MARK: - Init
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }

    // MARK: - private method transforms [TicketData] -> [TicketForUI]
    private func createUITicketsFrom(parsedTickets: [TicketData]) -> [TicketForUI] {
        parsedTickets.compactMap {
            guard let departureDate = DateManager.createDateFromString($0.departDate, incommingFormat: "yyyy-MM-dd"),
                  let arrivalDate = DateManager.createDateFromString($0.returnDate, incommingFormat: "yyyy-MM-dd") else {
                assertionFailure("canNot make date")
                return nil
            }

            let ticket = TicketForUI(
                city1: "\($0.origin)",
                city2: "\($0.destination)",
                departureDate: departureDate,
                arrivalDate: arrivalDate,
                price: $0.value,
                isLike: false
            )
            return ticket
        }
    }

}

// MARK: - Extensions
extension DataTransformer: DataTransformerProtocol {

    func makeTicketsFromData(at url: URL) async throws -> [TicketForUI] {
        let ticketsData = try await networkManager.getDecodedModel(using: url, model: TicketsDecoded.self) // если ошибка, то автоматически выбросится на уровень выше
        let ticketsForUI = createUITicketsFrom(parsedTickets: ticketsData.data)
        return ticketsForUI
    }

}

// GCD + completion: Result
// typealias DataTransformerCompletion = (Result<[TicketForUI], NetWorkManagerErrors>) -> Void
//
// protocol DataTransformerProtocol {
//    func makeTicketsFromData(_ completion: @escaping DataTransformerCompletion)
// }
//
// final class DataTransformer {
//
//    // MARK: - Private properties
//    private let networkManager: NetworkManagerProtocol
//    private let concurrentQueue = DispatchQueue(label: "concurrentQueueForTransformingData", qos: .userInteractive, attributes: .concurrent)
//
//
//    // MARK: - Init
//    init(networkManager: NetworkManagerProtocol) {
//        self.networkManager = networkManager
//    }
//
//
//    // MARK: - private method transforms TicketForUI -> [TicketForUI]
//    private func createUITicketsFrom(parsedTickets: [TicketData]) -> [TicketForUI] {
//        parsedTickets.compactMap {
//        guard let departureDate = DateManager.createDateFromString($0.departDate, incommingFormat: "yyyy-MM-dd"),
//              let arrivalDate = DateManager.createDateFromString($0.returnDate, incommingFormat: "yyyy-MM-dd") else {
//               assertionFailure("canNot make date")
//               return nil
//           }
//
//            let ticket = TicketForUI(
//                city1: "\($0.origin)",
//                city2: "\($0.destination)",
//                departureDate: departureDate,
//                arrivalDate: arrivalDate,
//                price: $0.value,
//                isLike: false
//            )
//            return ticket
//        }
//    }
// }
//
// MARK: - Extensions
// extension DataTransformer: DataTransformerProtocol {
//
//    func makeTicketsFromData(_ completion: @escaping DataTransformerCompletion) {
//        networkManager.getTicketsData { [weak self] result in
//            guard let self else {return}
//
//            switch result {
//            case .success(let ticketsData):
//                self.concurrentQueue.async {
//                    let ticketsForUI = self.createUITicketsFrom(parsedTickets: ticketsData)
//                    DispatchQueue.main.async {
//                        completion(.success(ticketsForUI))
//                    }
//                }
//
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//
// }
