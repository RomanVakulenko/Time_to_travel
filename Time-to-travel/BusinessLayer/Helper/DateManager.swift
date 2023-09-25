//
//  DateManager.swift
//  Time-to-travel
//
//  Created by Roman Vakulenko on 25.09.2023.
//

import Foundation

final class DateManager {
    static let dateFormatter = DateFormatter()

    static func createStringFromDate(_ date: Date, stringFormat: String) -> String? {
        dateFormatter.dateFormat = stringFormat
        return dateFormatter.string(from: date)
    }

    static func createDateFromString(_ string: String) -> Date? {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: string)
    }
}
