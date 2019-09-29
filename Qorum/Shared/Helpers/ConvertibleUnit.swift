//
//  ConvertibleUnit.swift
//  Qorum
//
//  Created by Stanislav on 17.12.2017.
//  Copyright © 2017 Bizico. All rights reserved.
//

struct UnitValue<Unit: RawRepresentable> where Unit.RawValue: FloatingPoint {
    
    let rawAmount: Unit.RawValue
    
    init(_ amount: Unit.RawValue, _ unit: Unit) {
        rawAmount = amount * unit.rawValue
    }
    
    func converted(to: Unit) -> Unit.RawValue {
        return rawAmount / to.rawValue
    }
    
    subscript(in unit: Unit) -> Unit.RawValue {
        return converted(to: unit)
    }
    
}

// MARK: - Comparable
extension UnitValue: Comparable {
    
    static func < (lhs: UnitValue<Unit>, rhs: UnitValue<Unit>) -> Bool {
        return lhs.rawAmount < rhs.rawAmount
    }
    
}

// MARK: - Angle

enum AngleUnit: CGFloat {
    case degrees = 0.0174532925199432951
    case radians = 1
}

typealias Angle = UnitValue<AngleUnit>

// MARK: - Time

enum TimeUnit: TimeInterval {
    case milliseconds = 0.001
    case seconds = 1
    case minutes = 60
    case hours = 3600
    case days = 86400
    case weeks = 604800
}

typealias Time = UnitValue<TimeUnit>

// MARK: - Distance

enum DistanceUnit: Double {
    case feet = 0.3048
    case meters = 1
    case kilometers = 1000
    case miles = 1609.34
}

typealias Distance = UnitValue<DistanceUnit>


// MARK: - Money

enum MoneyUnit: Double {
    case cents = 1
    case dollars = 100
}

typealias Money = UnitValue<MoneyUnit>

extension UnitValue where Unit == MoneyUnit {
    
    static let moneyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    var monetaryValue: String {
        if let formatted = Money.moneyFormatter.string(from: self[in: .dollars] as NSNumber) {
            return formatted
        }
        return "0.00"
    }
    
}
