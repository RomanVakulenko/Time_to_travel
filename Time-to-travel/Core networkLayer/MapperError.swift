//
//  MapperError.swift
//  Time-to-travel
//
//  Created by Roman Vakulenko on 22.09.2023.
//

import Foundation

enum MapperError: Error, CustomStringConvertible {
    case failParsed(reason: String)

    var description: String {
        switch self {
        case .failParsed(let reason):
            return reason
        }
    }
}
