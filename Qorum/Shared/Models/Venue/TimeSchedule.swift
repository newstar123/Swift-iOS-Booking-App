//
//  TimeSchedule.swift
//  Qorum
//
//  Created by Stanislav on 15.12.2017.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit

struct TimeSchedule {
    
    /// Opening Date
    let opening: Date
    
    /// Closing Date
    let closing: Date
    
    /// Returns working day duration
    var duration: TimeInterval {
        return closing.timeIntervalSince(opening)
    }
    
    /// Human-readable string for opening hours
    var displayString: String {
        let formatter = Venue.Status.indicatorDateFormatter
        let opens = formatter.string(from: opening)
        let closes = formatter.string(from: closing)
        return "\(opens) - \(closes)"
    }
    
    init(from timeSlot: TimeSlot, onDayOf date: Date, calendar: Calendar) {
        opening = timeSlot.start.date(onDayOf: date, calendar: calendar)
        if timeSlot.end < timeSlot.start {
            closing = timeSlot.end.date(onDayOf: date.addingTimeInterval(.dayInterval), calendar: calendar)
        } else {
            closing = timeSlot.end.date(onDayOf: date, calendar: calendar)
        }
    }
    
    /// Returns Open/Closed Venue status for given date
    ///
    /// - Parameter date: date to check
    /// - Returns: Venue Status
    func status(at date: Date) -> Venue.Status? {
        if opening <= date, date <= closing {
            let openingWeekday = opening.weekday
            if closing.timeIntervalSince(date) <= .hourInterval {
                return .closesSoon(at: closing, openedOn: openingWeekday)
            }
            return .open(openedOn: openingWeekday, closesAt: closing)
        }
        if date < opening, opening.timeIntervalSince(date) < .dayInterval {
            return .opensLater(at: opening)
        }
        return nil
    }
    
}

