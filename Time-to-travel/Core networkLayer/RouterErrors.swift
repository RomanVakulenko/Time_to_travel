//
//  RouterErrors.swift
//  Time-to-travel
//
//  Created by Roman Vakulenko on 18.09.2023.
//

import Foundation

enum RouterErrors: String, Error {
    case noData = "Data are nill"
    case noToken
    case unableToCreateRequest
    case unableToCreateURL
}
