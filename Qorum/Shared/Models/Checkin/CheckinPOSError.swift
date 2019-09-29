//
//  CheckIn409ErrorMetaCode.swift
//  Qorum
//
//  Created by D-Link Mac Mini on 6/22/18.
//  Copyright © 2018 Bizico. All rights reserved.
//

import Foundation

enum CheckinPOSError: String {
    case
    CURRENT_POS_ERROR,
    POS_ERROR_CHECKIN,
    POS_ERROR_CLOSE_CHECKIN,
    POS_ERROR_WITHOUT_CHECKIN,
    TAB_TICKET_CLOSED_EMPTY
    
    /// Error description for POS Error
    var message: String {
        switch self {
        case .CURRENT_POS_ERROR:
            return "There is an error with the POS system, leading to a 10-minute delay in updating your tab. Please try updating your tab in 10 minutes."
        case .POS_ERROR_CHECKIN:
            return "We're currently experiencing an issue with the POS system. When you're ready to close out your tab, please see the Bartender. Because of the inconvenience, you will receive a $15 Uber Promo Code via email."
        case .POS_ERROR_CLOSE_CHECKIN:
            return "We're currently experiencing an issue with the POS system. To close out your tab, please see the Bartender. Because of the inconvenience, you will receive a $15 Uber Promo Code via email."
        case .POS_ERROR_WITHOUT_CHECKIN:
            return "We're currently experiencing an issue with the POS system. To open, update, and close out your tab, please see the Bartender. Because of the inconvenience, you will receive a $15 Uber Promo Code via email."
        case .TAB_TICKET_CLOSED_EMPTY:
            return "Looks like your tab was closed before you got to order anything. Do you want to open a new tab?"
        }
    }
    
}
