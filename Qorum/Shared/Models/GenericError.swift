//
//  GenericError.swift
//  Qorum
//
//  Created by Dima Tsurkan on 9/25/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import Foundation
import SwiftyJSON
import UserNotifications

struct GenericError: Error {
    
    /// Error status
    let status: Int
    
    /// Error title
    let title: String
    
    /// Detailed description
    let detail: JSON
    
    /// Error metadata
    let meta: Meta?
    
    /// Error code
    let code: String
    
    /// Used to define the 3rd party service (like POS API) errors data
    struct Meta {
        /// Defines issue kind
        let code: String
        let message: String
    }
    
}

// MARK: - JSONAbleType
extension GenericError: JSONAbleType {
    
    static func from(json: JSON) -> GenericError {
        let status = json["status"].intValue
        let title = json["title"].stringValue
        let jsonDetail = json["detail"]
        let detail: JSON
        if let detailString = jsonDetail.string {
            if JSON(parseJSON: detailString).string.hasValue {
                let wrappedDetailJSON = JSON(parseJSON: "{\(detailString)}")
                if wrappedDetailJSON.string.hasValue {
                    detail = jsonDetail
                } else {
                    detail = wrappedDetailJSON
                }
            } else {
                let parsedJSON = JSON(parseJSON: detailString)
                detail = parsedJSON != .null ? parsedJSON : jsonDetail
            }
        } else {
            detail = jsonDetail
        }
        let meta = try? Meta.from(json: json["meta"])
        let code = json["code"].stringValue
        return GenericError(status: status,
                            title: title,
                            detail: detail,
                            meta: meta,
                            code: code)
    }
    
}

// MARK: - JSONAbleType
extension GenericError.Meta: JSONAbleType {
    
    static func from(json: JSON) throws -> GenericError.Meta {
        let code = try json["code"].expectingString()
        let message = json["message"].stringValue
        return GenericError.Meta(code: code, message: message)
    }
    
}

// MARK: -

protocol CustomError: LocalizedError, CustomStringConvertible {
    
}

extension CustomError {
    
    public var errorDescription: String? {
        return description
    }
    
}

// MARK: - CustomError
extension String: CustomError {
    
}

// MARK: -

func typeMismatch(expected: Any.Type, actual value: Any) -> Error {
    let actualType = type(of: value)
    guard expected != actualType else {
        return "Type matches - have \(actualType)(\(value))"
    }
    guard actualType != NSNull.self else {
        return "Value missing - expected \(expected)"
    }
    return "Type mismatch - expected \(expected); have \(actualType)(\(value))"
}

// MARK: -

extension Error {
    
    /// Returns human-readable message to present as alert
    var message: String {
        switch self {
        case let stringError as String:
            return stringError
        case let genericError as GenericError:
            return genericError.detail.description
        default:
            if AppConfig.developerModeEnabled {
                return "\(localizedDescription)\n\(self)"
            }
            return localizedDescription
        }
    }
    
    /// Posts User Notification if Developer Mode Enabled
    ///
    /// - Parameters:
    ///   - title: alert title
    ///   - statusCode: error status code
    ///   - completion: completion block
    func developerModeAlert(title: String,
                            statusCode: Int? = nil,
                            completion: @escaping ()->()) {
        guard AppConfig.developerModeEnabled else {
            completion()
            return
        }
        // We don't need to show the developer mode alert in case we just need to register the patron
        if let genericError = self as? GenericError,
            genericError.status == 401,
            genericError.message == "No patron matching facebook profile"
        {
            completion()
            return
        }
        var alertTitle = "Dev Mode Error\n\(title)"
        var alertMessage = ""
        if let code = statusCode {
            alertMessage.append("Status \(code)\n")
        }
        alertMessage.append(message)
        if let genericError = self as? GenericError {
            if genericError.title.isNotEmpty {
                alertTitle.append("\n")
                alertTitle.append(genericError.title)
            }
            if let metaMessage = genericError.meta?.message, metaMessage.isNotEmpty {
                alertMessage.append("\nMeta: ")
                alertMessage.append(metaMessage)
            }
        }
        
        QorumProgressHUD.dismiss()
        
        switch UIApplication.shared.applicationState {
        case .active:
            let actions: [UIAlertController.CustomAction]
            actions = [("Close", .cancel, completion),
                       ("Copy text", .default, {
                        UIPasteboard.general.string = "\(alertTitle)\n\n\(alertMessage)"
                        completion()
                       })]
            UIAlertController.presentAsAlert(title: alertTitle,
                                             message: alertMessage,
                                             actions: actions)
        case .background, .inactive:
            let devModeCategory = UNNotificationCategory(
                identifier: QorumPushIdentifier.devModeError.rawValue,
                actions: [],
                intentIdentifiers: [],
                options: [])
            
            UNUserNotificationCenter.current().setNotificationCategories([devModeCategory])
            
            let content = UNMutableNotificationContent.create(with: alertTitle,
                                                              body: alertMessage,
                                                              categoryIdentifier: devModeCategory.identifier)
            VenueTrackerNotifier.showNotification(with: devModeCategory.identifier, content: content)
            completion()
        }
    }
    
}
