//
//  QorumVerificationAPI.swift
//  Qorum
//
//  Created by Stanislav on 18.04.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit
import Moya

enum QorumVerificationAPI {
    case startPhoneVerification(userId: Int, countryCode: String, phoneNumber: String)
    case checkPhoneVerification(userId: Int, countryCode: String, phoneNumber: String, code: String)
}

// MARK: - QorumAPITarget
extension QorumVerificationAPI: QorumAuthenticatedAPITarget {
    
    var path: String {
        switch self {
        case let .startPhoneVerification(userId, _, _):
            return "/api/v2/patrons/\(userId)/verification/phone/start"
        case let .checkPhoneVerification(userId, _, _, _):
            return "/api/v2/patrons/\(userId)/verification/phone/check"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .startPhoneVerification, .checkPhoneVerification:
            return .post
        }
    }
    
    var task: Task {
        let parameters: [String: String]
        switch self {
        case let .startPhoneVerification(_, countryCode, phoneNumber):
            parameters = ["country_code": countryCode,
                          "phone_number": phoneNumber]
        case let .checkPhoneVerification(_, countryCode, phoneNumber, code):
            parameters = ["country_code": countryCode,
                          "phone_number": phoneNumber,
                          "verification_code": code]
        }
        return .requestParameters(parameters: parameters,
                                  encoding: JSONEncoding.default)
    }
    
}

