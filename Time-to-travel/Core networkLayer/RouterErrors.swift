//
//  RouterErrors.swift
//  Time-to-travel
//
//  Created by Roman Vakulenko on 18.09.2023.
//

import Foundation

enum RouterErrors: Error, CustomStringConvertible {
    case noData(reason: String)
    case unableToCreateRequest
    
    var description: String {
        switch self {
        case .noData(let reason):
            return reason
        case .unableToCreateRequest:
            return "unableToCreateRequest"
        }
    }
}
