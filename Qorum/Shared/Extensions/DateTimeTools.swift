//
//  DateTimeTools.swift
//  Qorum
//
//  Created by Stanislav on 19.12.2017.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit

extension Date {
    
    /// Returns Date Formatter for date in medium format
    static let birthdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.timeZone = .utc
        return formatter
    }()
    
    /// Returns Date Formatter for date in format MM/dd/yyyy
    static let apiBirthdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        formatter.timeZone = .utc
        return formatter
    }()
    
    /// Returns Date Formatter for date in format MM dd yyyy
    static let checkAgeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM dd yyyy"
        formatter.timeZone = .utc
        return formatter
    }()
    
    /// Returns Date Formatter for date in format yyyy-MM-dd'T'HH:mm:ss.SSSZ
    static let standardDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = .utc
        return dateFormatter
    }()
    
    /// Returns human-readable date in medium format
    var birthdayString: String {
        return Date.birthdayFormatter.string(from: self)
    }

    /// Returns human-readable date in format yyyy-MM-dd'T'HH:mm:ss.SSSZ
    var backendString: String {
        return Date.standardDateFormatter.string(from: self)
    }

    /// Returns weekday
    var weekday: Weekday {
        return Weekday(date: self)
    }
    
    /// Returns weekday for UTC time zone
    var utcWeekday: Weekday {
        return Weekday(date: self, timeZone: .utc)
    }
    
    /// Returns weekday for given time zone
    func weekday(timeZone: TimeZone) -> Weekday {
        var calendar = Weekday.calendar
        calendar.timeZone = timeZone
        let component = calendar.component(.weekday, from: self)
        return Weekday.allCases.first { $0.component == component }!
    }
    
}

extension TimeZone {
    
    static let enumerated: [TimeZone] = {
        var timeZones: [TimeZone] = []
        for i in 0...24 {
            let offset = (i-12) * Int(.hourInterval)
            timeZones.append(TimeZone(secondsFromGMT: offset)!)
        }
        return timeZones
    }()
    
    /// Returns UTC time zone
    static let utc: TimeZone = {
        return TimeZone(identifier: "UTC")!
    }()
    
}

extension TimeInterval {
    
    /// Returns time interval in seconds for day
    static let dayInterval: TimeInterval = {
        return seconds(in: 1, .days)
    }()

    /// Returns time interval in seconds for hours
    static let hourInterval: TimeInterval = {
        return seconds(in: 1, .hours)
    }()
    
    /// Returns seconds amount for given time interval
    ///
    /// - Parameters:
    ///   - amount: time interval
    ///   - unit: time unit to calculate, i.e., seconds, minutes, hours, etc.
    /// - Returns: time interval in seconds
    static func seconds(in amount: TimeInterval, _ unit: TimeUnit) -> TimeInterval {
        return Time(amount, unit).converted(to: .seconds)
    }
    
}


