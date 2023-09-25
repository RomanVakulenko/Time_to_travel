//
//  NetWorkManagerErrors.swift
//  Time-to-travel
//
//  Created by Roman Vakulenko on 23.09.2023.
//

import Foundation

enum NetWorkManagerErrors: Error, CustomStringConvertible {
    case networkRouterError(error: RouterErrors)
    case mapperError(error: MapperError)
    case wrongURL

    var description: String {
        switch self {
        case .networkRouterError(let error):
            return error.description
        case .mapperError(let error):
            return error.description
        case .wrongURL:
            return "wrongURL"

        }
    }

}
