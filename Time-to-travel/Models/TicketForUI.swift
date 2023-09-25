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
    var departureDateString: String
    var arrivalDateString: String 
    var price: Int

    init(city1: String, city2: String, departureDateString: String, arrivalDateString: String, price: Int) {
        self.city1 = city1
        self.city2 = city2
        self.departureDateString = departureDateString
        self.arrivalDateString = arrivalDateString
        self.price = price
    }
}

