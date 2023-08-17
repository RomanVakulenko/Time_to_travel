//
//  FlightInfo.swift
//  time-to-travel
//
//  Created by Roman Vakulenko on 06.08.2023.
//

import UIKit

struct FlightTicket {
    let city1: String
    let city2: String
    let departureDate: Date
    let arrivalDate: Date
    let price: Int
    var isLike: Bool
}

// MARK: - Mock data
func getMockData() -> [FlightTicket] {
    var resultArray: [FlightTicket] = []
    for number in 0...19 {
        let newTicket = FlightTicket(
            city1: "Город №\(number)",
            city2: "Город №\(number)X",
            departureDate: Date.now,
            arrivalDate: Date.now,
            price: number,
            isLike: false
        )
        resultArray.append(newTicket)
    }
    return resultArray
}
