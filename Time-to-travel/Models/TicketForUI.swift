//
//  TicketForUI.swift
//  Time-to-travel
//
//  Created by Roman Vakulenko on 31.08.2023.
//

import Foundation

struct TicketForUI { //множественное число или единственное
    let city1: String
    let city2: String
    let departureDateString: String
//    var departureDate: Date {
//        Date() //пока вопрос - надо ли декодировать в дату, если потом снова нужна строка...?
//    }
    let arrivalDateString: String
//    var arrivalDate: Date {
//        Date() //пока вопрос - надо ли декодировать в дату, если потом снова нужна строка...?
//    }
    let price: Int

    init?(ticketData: [TicketData]) {  // failable если не удастся сделать - то вернет nil
        guard let ticket = ticketData.first else { return nil }
        
        self.city1 = ticket.origin
        self.city2 = ticket.destination
        self.departureDateString = ticket.departDate
        self.arrivalDateString = ticket.returnDate //даты прибытия не было - взял дату обратного билета
        self.price = ticket.value
    }
}
