//
//  APIResponse.swift
//  Qorum
//
//  Created by Stanislav on 17.08.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit
import SwiftyJSON
import Moya

struct APIResponse<Value> {
    
    let endpointDescriptor: QorumEndpointDescriptor
    let urlResponse: HTTPURLResponse?
    let result: APIResult<Value>
    
    var endpoint: String {
        return endpointDescriptor.endpointDescription
    }
    
    var statusCode: Int? {
        return urlResponse?.statusCode
    }
    
    func validate(completion: @escaping () -> ()) {
        switch result {
        case .value:
            // must do nothing here, otherwise this line may be executed multiple times
            completion()
        case .error(let error):
            print("Failed to perform request with endpoint:", endpoint, "\nError:", error)
            error.developerModeAlert(title: endpoint,
                                     statusCode: statusCode,
                                     completion: completion)
        }
    }
    
}

enum APIResult<Value> {
    case value(Value)
    case error(Swift.Error)
}

extension APIResult where Value == Void {
    
    static let success: APIResult<Void> = .value(())
    
}

typealias APIHandler<Value> = (APIResult<Value>) -> Void

extension Response {
    
    /// indicates whether it is succesful response
    /// returns true if status code is in range of 200...208
    var isOk: Bool {
        switch statusCode {
        case 200...208:
            return true
        default:
            return false
        }
    }
    
    var jsonResult: APIResult<JSON> {
        do {
            let json = try parseJSON()
            if let errorJSON = json["errors"].array?.first, json["meta"].dictionaryObject == nil {
                return .error(GenericError.from(json: errorJSON))
            }
            return .value(json)
        } catch let error {
            return .error(error)
        }
    }
    
    private func parseJSON() throws -> JSON {
        do {
            let jsonObject = try mapJSON()
            return JSON(jsonObject)
        } catch let error {
            let stringResponse = try? mapString()
            if isOk {
                return JSON(stringResponse ?? "OK")
            }
            print("String response:\n\(stringResponse ?? "nil")")
            throw error
        }
    }
    
}

