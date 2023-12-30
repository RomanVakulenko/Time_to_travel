//
//  Mapper.swift
//  Time-to-travel
//
//  Created by Roman Vakulenko on 18.09.2023.
//

import Foundation

protocol MapperProtocol {
    func decode<T: Decodable> (from data: Data, toStruct: T.Type) throws -> T
}

final class DataMapper {

    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

}

// MARK: - Extensions
extension DataMapper: MapperProtocol {
    // вариант для async await подхода
    func decode<T: Decodable> (from data: Data, toStruct: T.Type) throws -> T {
        do {
            let decodedModel = try self.decoder.decode(toStruct, from: data)
            return decodedModel
        } catch let error as DecodingError {
            let errorLocation = "in File: \(#file), at Line: \(#line), Column: \(#column)"
            throw MapperError.failParsed(reason: "\(error), \(errorLocation)")
        } catch {
            print("Unknown error have been caught in File: \(#file), at Line: \(#line), Column: \(#column)")
            throw error
        }
    }

}

// GCD + completion generic and result
// typealias MapperCompletion<T: Decodable> = (Result<T, MapperError>) -> Void
//
// protocol MapperProtocol {
//    func decode<T: Decodable> (from data: Data, toStruct: T.Type, completion: @escaping MapperCompletion<T>)
// }
//
//
// final class DataMapper {
//
//    private lazy var decoder: JSONDecoder = {
//        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
//        return decoder
//    }()
//
//    private let concurrentQueque = DispatchQueue(label: "concurrentForParsing", qos: .userInitiated, attributes: .concurrent)
// }
//
//
// MARK: - Extensions
// extension DataMapper: MapperProtocol {
//    func decode<T>(from data: Data, toStruct: T.Type, completion: @escaping MapperCompletion<T>) where T : Decodable {
//        concurrentQueque.async {
//            do {
//                let parsedTickets = try self.decoder.decode(toStruct, from: data)
//                DispatchQueue.main.async {
//                    completion(.success(parsedTickets))
//                }
//            }
//            catch {
//                DispatchQueue.main.async {
//                    completion(.failure(.failParsed(reason: "ошибка декодирования")))
//                }
//            }
//        }
//    }
//
// }
