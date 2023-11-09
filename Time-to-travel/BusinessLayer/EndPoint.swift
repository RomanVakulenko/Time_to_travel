//
//  EndPoint.swift
//  Time-to-travel
//
//  Created by Roman Vakulenko on 02.10.2023.
//

import Foundation

final class EndPont {
    private init() {}
    static var shared = EndPont()

    private var baseURL: String {
        return "http://api.travelpayouts.com"
    }

    func urlFor(variant: Variant) -> URL? {
        var urlComponents = URLComponents(string: baseURL + variant.path)
        urlComponents?.queryItems = variant.queryItems
        return urlComponents?.url
    }
}

extension EndPont {

    enum Variant {
        case pricesForLatest
    //  case ...

        var path: String {
            switch self {
            case .pricesForLatest:
                return "/v2/prices/latest"
            }
    //      case ...
        }

        var queryItems: [URLQueryItem] {
            switch self {
            case .pricesForLatest:
                return [
                    URLQueryItem(name: "currency", value: "rub"),
                    URLQueryItem(name: "period_type", value: "year"),
                    URLQueryItem(name: "page", value: "1"),
                    URLQueryItem(name: "limit", value: "30"),
                    URLQueryItem(name: "show_to_affiliates", value: "false"),
                    URLQueryItem(name: "token", value: Use.token)
                ]
            }
    //      case ...
        }
    }
}
