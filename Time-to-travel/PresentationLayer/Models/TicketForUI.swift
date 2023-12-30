//
//  TicketForUI.swift
//  Time-to-travel
//
//  Created by Roman Vakulenko on 31.08.2023.
//

import Foundation

struct TicketForUI {
    var city1: String
    var city2: String
    var departureDate: Date
    var arrivalDate: Date
    var price: Int
    var isLike: Bool

    init(city1: String, city2: String, departureDate: Date, arrivalDate: Date, price: Int, isLike: Bool) {
        self.city1 = city1
        self.city2 = city2
        self.departureDate = departureDate
        self.arrivalDate = arrivalDate
        self.price = price
        self.isLike = false
    }
}
