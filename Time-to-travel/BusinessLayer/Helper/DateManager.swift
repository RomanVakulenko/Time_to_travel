//
//  DateManager.swift
//  Time-to-travel
//
//  Created by Roman Vakulenko on 25.09.2023.
//

import Foundation

final class DateManager {
    static let dateFormatter = DateFormatter()

    static func createDateFromString(_ string: String, incommingFormat format: String) -> Date? {
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter.date(from: string)
    }

    static func createStringFromDate(_ date: Date, andFormatTo format: String, timeZoneInSecondFromGMT: Int = 0) -> String {
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: timeZoneInSecondFromGMT)
        return dateFormatter.string(from: date)
    }
    // в методе .createStringFromDate есть параметр timeZoneInSecondFromGMT: Int
    // туда надо подставлять значение часового пояса города отправления
    // и значение часового пояса города прибытия
    // Известно, что дата и время указывается в часовом поясе аэропорта прибытия/отправления
    // У параметра timeZoneInSecondFromGMT: Int есть дефолтное значение "= 0" так как с бэка нам не приходят эти данные, поэтому оставил 0
}
