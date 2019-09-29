//
//  OSLogDestination.swift
//  Qorum
//
//  Created by Dmitry Tsurkan on 2/19/19.
//  Copyright © 2019 Bizico. All rights reserved.
//

import Foundation
import os
import SwiftyBeaver

final class OSLogDestination: BaseDestination {
    
    fileprivate let level: SwiftyBeaver.Level
    
    init(level: SwiftyBeaver.Level) {
        self.level = level
    }
    
    override func send(_ level: SwiftyBeaver.Level,
                       msg: String,
                       thread: String,
                       file: String,
                       function: String,
                       line: Int,
                       context: Any?) -> String? {
        
        if level.rawValue >= self.level.rawValue {
            
            let log = self.createOSLog(context: context)
            
            os_log("%@.%@:%i - \n%@",
                   log: log,
                   type: self.osLogLevelRelated(to: level),
                   file, function, line, msg)
        }
        
        return super.send(level,
                          msg: msg,
                          thread: thread,
                          file: file,
                          function: function,
                          line: line)
    }
    
}

private extension OSLogDestination {
    
    func createOSLog(context: Any?) -> OSLog {
        var currentContext = "Default"
        if let loggerContext = context as? String {
            currentContext = loggerContext
        }
        let subsystem = Bundle.main.bundleIdentifier ?? "com.logger.default"
        let customLog = OSLog(subsystem: subsystem, category: currentContext)
        return customLog
    }
    
    func osLogLevelRelated(to swiftyBeaverLogLevel: SwiftyBeaver.Level) -> OSLogType {
        var logType: OSLogType
        switch swiftyBeaverLogLevel {
        case .debug:
            logType = .debug
        case .verbose:
            logType = .default
        case .info:
            logType = .info
        case .warning:
            //We use "error" here because of 🔶 indicator in the Console
            logType = .error
        case .error:
            //We use "fault" here because of 🔴 indicator in the Console
            logType = .fault
        }
        
        return logType
    }
}

extension SwiftyBeaver {
    
    static func setupConsole() {
        let console = ConsoleDestination()
        console.levelColor.verbose = "⚪️ "
        console.levelColor.debug = "☑️ "
        console.levelColor.info = "🔵 "
        console.levelColor.warning = "🔶 "
        console.levelColor.error = "🔴 "
        #if DEBUG
        console.minLevel = .verbose
        #else
        console.minLevel = .error
        #endif
        
        SwiftyBeaver.self.addDestination(console)
    }
    
    static func addOSLogDestination() {
        #if DEBUG
        let level: SwiftyBeaver.Level = .verbose
        #else
        let level: SwiftyBeaver.Level = .error
        #endif
        let osLogDestination = OSLogDestination(level: level)
        SwiftyBeaver.self.addDestination(osLogDestination)
    }
    
    private static var osLogDestination: OSLogDestination = {
        #if DEBUG
        let level: SwiftyBeaver.Level = .verbose
        #else
        let level: SwiftyBeaver.Level = .error
        #endif
        let osLogDestination = OSLogDestination(level: level)
        return osLogDestination
    }()
    
    static func setOSLog(enabled: Bool) {
        if enabled {
            SwiftyBeaver.self.addDestination(SwiftyBeaver.osLogDestination)
        } else {
            SwiftyBeaver.self.removeDestination(SwiftyBeaver.osLogDestination)
        }
    }
}
