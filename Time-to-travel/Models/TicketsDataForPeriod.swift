//
//  TicketsDataForPeriod.swift
//  Time-to-travel
//
//  Created by Roman Vakulenko on 31.08.2023.
//

import Foundation

struct TicketsDataForPeriod: Decodable { //структура в которую декодируем JSON
    let data: [TicketData]
}

struct TicketData: Decodable {
    let origin: String
    let departDate: Date
    let destination: String
    let returnDate: Date //даты прибытия не было - взял дату обратного билета
    let value: Int

    enum CodingKeys: String, CodingKey {
    case origin
    case departDate = "depart_date"  //пришел в snake_case, надо перевести в camelCase
    case destination
    case returnDate = "return_date"
    case value

    }
}
