//
//  NetWorkManagerErrors.swift
//  Time-to-travel
//
//  Created by Roman Vakulenko on 23.09.2023.
//

import Foundation

enum NetWorkManagerErrors: Error, CustomStringConvertible {
    case show
    case networkRouterError(error: RouterErrors)
    case mapperError(error: MapperError)

    var description: String {
        switch self {
        case .show:
            return "some error"
        case .networkRouterError(let error):
            return error.description
        case .mapperError(let error):
            return error.description
        }
    }

    var descriptionForUser: String {
        switch self {
        case .networkRouterError(let error):
            switch error {
            case .noInternetConnection: // увидит реальную ошибку
                return error.description
            default: // в любом ином случае увидит это:
                return "Ошибка соединения с сервером"
            }
        default: // в любом ином случае увидит это:
            return "Ошибка соединения с сервером"
        }
    }

}
