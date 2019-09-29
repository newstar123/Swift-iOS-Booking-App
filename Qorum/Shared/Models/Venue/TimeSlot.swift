//
//  TimeSlot.swift
//  Qorum
//
//  Created by Stanislav on 15.12.2017.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit

enum Weekday: String, CaseIterable {
    case monday = "mon"
    case tuesday = "tue"
    case wednesday = "wed"
    case thursday = "thu"
    case friday = "fri"
    case saturday = "sat"
    case sunday = "sun"
    
    init(date: Date, timeZone: TimeZone = .current) {
        var calendar = Weekday.calendar
        calendar.timeZone = timeZone
        let component = calendar.component(.weekday, from: date)
        self = Weekday(component: component)!
    }
    
    init?(component: Int) {
        if let day = Weekday.allCases.first(where: { $0.component == component }) {
            self = day
        } else {
            return nil
        }
    }
    
    var component: Int {
        switch self {
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        case .sunday: return 1
        }
    }
    
    /// Localized title for date component
    var localizedName: String {
        return Weekday.calendar.standaloneWeekdaySymbols[component-1]
    }
    
    /// Returns date representing first day of the week with given date
    ///
    /// - Parameter date: Reference date
    /// - Returns: Resulting date
    func startOfDay(inWeekContaining date: Date) -> Date {
        let calendar = Weekday.calendar
        let weekDate = calendar.date(byAdding: .weekday,
                                     value: component - date.weekday.component,
                                     to: date)!
        return calendar.startOfDay(for: weekDate)
    }
    
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = .current
        calendar.timeZone = .current
        calendar.firstWeekday = 1
        return calendar
    }()
    
}

class TimeSlot: NSObject {
    
    private(set) var weekdayString = "mon"
    private(set) var startString = "0:0"
    private(set) var endString = "0:1"
    
    /// Returns weekday
    var weekday: Weekday {
        return Weekday(rawValue: weekdayString) ?? .monday
    }
    
    /// Returns TimeSlot's start componented date
    var start: Components {
        return Components(string: startString) ?? Components(hour: 0, minute: 0)
    }
    
    /// Returns TimeSlot's end componented date
    var end: Components {
        return Components(string: endString) ?? Components(hour: 0, minute: 1)
    }
    
    /// Parses string and returns TimeSlot instance
    ///
    /// - Parameter string: given string
    /// - Returns: resulting TimeSlot
    static func from(string: String?) -> TimeSlot? {
        guard let string = string else { return nil }
        let triplet = string.components(separatedBy: "/")
        guard triplet.count > 2 else { return nil }
        let weekdayString = triplet[0].lowercased()
        guard
            Weekday(rawValue: weekdayString) != nil,
            Components(string: triplet[1]) != nil,
            Components(string: triplet[2]) != nil else { return nil }
        let timeSlot = TimeSlot()
        timeSlot.weekdayString = weekdayString
        timeSlot.startString = triplet[1]
        timeSlot.endString = triplet[2]
        return timeSlot
    }
    
    /// Returns Schedule instance for certain date
    ///
    /// - Parameters:
    ///   - date: given Date
    ///   - calendar: Calendar instance
    /// - Returns: TimeSchedule instance
    func schedule(onDayOf date: Date, calendar: Calendar) -> TimeSchedule {
        return TimeSchedule(from: self, onDayOf: date, calendar: calendar)
    }
    
    struct Components {
        
        /// Hours component
        let hour: Int
        
        /// Minutes component
        let minute: Int
        
        init(hour rawHour: Int, minute rawMinute: Int) {
            if rawHour >= 24 {
                hour = 0
            } else {
                hour = max(0, rawHour)
            }
            minute = min(max(0, rawMinute), 59)
        }
        
        init?(string: String) {
            let components = string.components(separatedBy: ":")
            guard components.count > 0, let hour = Int(components[0]) else { return nil }
            guard components.count > 1, let minute = Int(components[1]) else {
                self.init(hour: hour, minute: 0)
                return
            }
            self.init(hour: hour, minute: minute)
        }
        
        /// Returns Date using current components
        ///
        /// - Parameters:
        ///   - date: referencing Daate
        ///   - calendar: Calendar instance
        /// - Returns: Resulting Date
        func date(onDayOf date: Date = Date(), calendar: Calendar) -> Date {
            return calendar.date(bySettingHour: hour,
                                 minute: minute,
                                 second: 0,
                                 of: date)!
        }
        
    }
    
}

// MARK: - Comparable
extension TimeSlot.Components: Comparable {
    
    static func <(lhs: TimeSlot.Components, rhs: TimeSlot.Components) -> Bool {
        return lhs.hour < rhs.hour || (lhs.hour == rhs.hour && lhs.minute < rhs.minute)
    }
    
    static func ==(lhs: TimeSlot.Components, rhs: TimeSlot.Components) -> Bool {
        return lhs.hour == rhs.hour && lhs.minute == rhs.minute
    }
    
}

// MARK: - [TimeSlot]
extension Collection where Element: TimeSlot {
    
    func schedule(onDayOf date: Date = Date(), calendar: Calendar) -> TimeSchedule? {
        let weekday = date.weekday
        guard let timeSlot = first(where: { $0.weekday == weekday }) else { return nil }
        return timeSlot.schedule(onDayOf: date, calendar: calendar)
    }
    
    func schedules(forWeekContaining date: Date = Date(),
                   calendar: Calendar = .current) -> [TimeSchedule] {
        var schedules: [TimeSchedule] = []
        for slot in self {
            let startOfDay = slot.weekday.startOfDay(inWeekContaining: date)
            let schedule = slot.schedule(onDayOf: startOfDay, calendar: calendar)
            schedules.append(schedule)
        }
        return schedules
    }
    
}

