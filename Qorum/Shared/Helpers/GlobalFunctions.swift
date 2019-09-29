//
//  GlobalFunctions.swift
//  Qorum
//
//  Created by Dima Tsurkan on 9/25/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import Foundation
import Reachability

// Ideally a Pod. For now a file.

/// Executes block on main thread after delay
///
/// - Parameters:
///   - delay: Delay value from now
///   - closure: The work item to be invoked on the queue
func delayToMainThread(_ delay: Double, closure: @escaping ()->()) {
    DispatchQueue.main.asyncAfter (deadline: .now() + delay,
                                   execute: closure)
}

/// Returns path to log file stored on the device
///
/// - Returns: URL to log file
func logPath() -> URL {
    let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    return docs.appendingPathComponent("logger.txt")
}

/// Logger instance
let logger = Logger(destination: logPath())

/// Detects development environment
///
/// - Returns: true if runs on simulator or built with debug configuration
func detectDevelopmentEnvironment() -> Bool {
    var developmentEnvironment = false
    #if DEBUG || (arch(i386) || arch(x86_64)) && os(iOS)
        developmentEnvironment = true
    #endif
    return developmentEnvironment
}


/// Throws fatal error for debug configuration or prints in log for production
///
/// - Parameter error: given error
func bindingErrorToInterface(_ error: Swift.Error) {
    let error = "Binding error to UI: \(error)"
    #if DEBUG
        fatalError(error)
    #else
        print(error)
    #endif
}

// Applies an instance method to the instance with an unowned reference.
func applyUnowned<Type: AnyObject, Parameters, ReturnValue>(_ instance: Type, _ function: @escaping ((Type) -> (Parameters) -> ReturnValue)) -> ((Parameters) -> ReturnValue) {
    return { [unowned instance] parameters -> ReturnValue in
        return function(instance)(parameters)
    }
}

