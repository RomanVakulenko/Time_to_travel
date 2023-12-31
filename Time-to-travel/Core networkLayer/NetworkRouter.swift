//
//  NetworkRouter.swift
//  Time-to-travel
//
//  Created by Roman Vakulenko on 22.09.2023.
//

import Foundation
// вариант с async await
protocol NetworkRouterProtocol {
    func requestDataWith(_ url: URL) async throws -> Data
}

final class NetworkRouter {

}

// MARK: - Extensions
extension NetworkRouter: NetworkRouterProtocol {

    // вариант с async await
    func requestDataWith(_ url: URL) async throws -> Data {
        do {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 10// if сервер не ответит
            configuration.timeoutIntervalForResource = 20// if загрузка data не завершится
            let session = URLSession(configuration: configuration)

            let (data, response) = try await session.data(from: url)
            if response is HTTPURLResponse {
                let statusCode = 500
                if statusCode < 200 && statusCode > 299 {
                    throw URLError(.badServerResponse) //The URL Loading System received bad data from the server.
                }
            }
            return data
        } catch let error as URLError {
            switch error.code {
            case .badServerResponse:
                throw RouterErrors.badURL
            case .notConnectedToInternet:
                throw RouterErrors.noInternetConnection
            case .timedOut:
                print("Ошибка: Превышено время ожидания")
            default:
                throw RouterErrors.serverErrorWith(error.code.rawValue)
            }
            throw error
        }
    }
}

    // вариант с GCD + completion
    // typealias NetworkRouterCompletion = (Result<Data, RouterErrors>) -> Void
    //
    // protocol NetworkRouterProtocol {
    //    func requestDataWith(_ urlRequest: URLRequest, completion: @escaping NetworkRouterCompletion)
    // }
    //
    //
    // final class NetworkRouter {
    //
    // }
    //
    //
    // MARK: - Extensions
    // extension NetworkRouter: NetworkRouterProtocol {
    //
    //    func requestDataWith(_ urlRequest: URLRequest, completion: @escaping NetworkRouterCompletion) {
    //        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
    //            guard error == nil else {
    //                DispatchQueue.main.async { completion(.failure(RouterErrors.noInternetConnection)) }
    //                return
    //            }
    //
    //            guard let httpResponse = response as? HTTPURLResponse else {
    //                DispatchQueue.main.async { completion(.failure(RouterErrors.badStatusCode(code: 0))) }
    //                return
    //            }
    //            let statusCode = httpResponse.statusCode
    //            if statusCode != 200 {
    //                DispatchQueue.main.async { completion(.failure(RouterErrors.badStatusCode(code: statusCode))) }
    //                return
    //            }
    //
    //            guard let data = data else {
    //                DispatchQueue.main.async { completion(.failure(RouterErrors.unableToCreateRequest)) }
    //                return
    //            }
    //            DispatchQueue.main.async { completion(.success(data)) }
    //
    //        }.resume()
    //    }
    //
    // }

    //
    // public enum HTTPMethod: String {
    //    case get = "GET"
    //    case post = "POST"
    //    case put = "PUT"
    //    case patch = "PATCH"
    //    case delete = "DELETE"
    // }
    //
    // protocol EndPointType {
    //    var baseURL: URL {get}
    //    var path: String {get}
    //    var httpMethod: HTTPMethod {get}
    ////    var task: HTTPTask {get}
    ////    var headers: HTTPHeaders? {get}
    // }
    // enum NetworkEnvironment {
    //    case qa
    //    case production
    //    case staging
    // }
    // struct NetManager {
    //    static var enivironment: NetworkEnvironment = .production
    // }
    // public enum MovieApi {
    //    case recommended(id:Int)
    //    case popular(page:Int)
    //    case newMovies(page:Int)
    //    case video(id:Int)
    // }
    // extension MovieApi: EndPointType {
    //    var environmentBaseURL : String {
    //        switch NetworkEnvironment.production {
    //        case .production: return "https://api.themoviedb.org/3/movie/"
    //        case .qa: return "https://qa.themoviedb.org/3/movie/"
    //        case .staging: return "https://staging.themoviedb.org/3/movie/"
    //        }
    //    }
    //    var baseURL: URL {
    //        guard let url = URL(string: environmentBaseURL) else { fatalError("baseURL could not be configured.")}
    //        return url
    //    }
    //    var path: String {
    //        switch self {
    //        case .recommended(let id):
    //            return "\(id)/recommendations"
    //        case .popular:
    //            return "popular"
    //        case .newMovies:
    //            return "now_playing"
    //        case .video(let id):
    //            return "\(id)/videos"
    //        }
    //    }
    //    var httpMethod: HTTPMethod {
    //        return .get
    //    }
    //    var task: HTTPTask {
    //        switch self {
    //        case .newMovies(let page):
    //            return .requestParameters(bodyParameters: nil,
    //                                      urlParameters: ["page":page,
    //                                                      "api_key":NetworkManager.MovieAPIKey])
    //        default:
    //            return .request
    //        }
    //    }
    //
    //    var headers: HTTPHeaders? {
    //        return nil
    //    }
    // }
