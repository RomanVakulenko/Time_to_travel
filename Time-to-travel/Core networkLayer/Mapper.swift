//
//  Mapper.swift
//  Time-to-travel
//
//  Created by Roman Vakulenko on 18.09.2023.
//

import Foundation

typealias MapperCompletion<T: Decodable> = (Result<T, MapperError>) -> Void

protocol Mapper {
    func decode<T: Decodable> (from data: Data, toTicketStruct: T.Type, completion: @escaping MapperCompletion<T>)
}


final class DataMapper {

    private lazy var decoder: JSONDecoder = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" //"yyyy-MM-dd HH:mm:ss ZZZZ zzz" -> "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    private let concurrentQueque = DispatchQueue(label: "concurrentForParsing", qos: .userInitiated, attributes: .concurrent)
}


// MARK: - Extensions
extension DataMapper: Mapper {
    func decode<T>(from data: Data, toTicketStruct: T.Type, completion: @escaping MapperCompletion<T>) where T : Decodable {
        concurrentQueque.async {
            do {
                let parsedTickets = try self.decoder.decode(toTicketStruct, from: data)
                DispatchQueue.main.async {
                    completion(.success(parsedTickets))
                }
            }
            catch {
                DispatchQueue.main.async {
                    completion(.failure(.failParsed(reason: "ошибка декодирования")))
                }
            }
        }
    }

}
