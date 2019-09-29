//
//  UberErrorInfo.swift
//  Qorum
//
//  Created by Vadym Riznychok on 3/20/18.
//  Copyright © 2018 Bizico. All rights reserved.
//

import Foundation

let kUberPaymentErrorCodesList: [String: UberErrorInfo] = [
    "invalid_payment":
        UberErrorInfo(errorInfo: "Sorry for the inconvenience - Uber has marked your payment method invalid.",
                      additionalInfo: "Please change your default payment method or add a new one."),
    "invalid_payment_method":
        UberErrorInfo(errorInfo: "Sorry for the inconvenience - The payment method ID sent to Uber is not valid.",
                      additionalInfo: "Please change your default payment method or add a new one."),
    "outstanding_balance_update_billing":
        UberErrorInfo(errorInfo: "Sorry for the inconvenience - Your Uber account has outstanding balances.",
                      additionalInfo: "Please change your default payment method or add a new one. If you receive this error again after changing your default payment method, please contact Uber Customer Support."),
    "insufficient_balance":
        UberErrorInfo(errorInfo: "Sorry for the inconvenience - Your credit card has an insufficient balance.",
                      additionalInfo: "Please change your default payment method or add a new one."),
    "payment_method_not_allowed":
        UberErrorInfo(errorInfo: "Sorry for the inconvenience - Uber does not accept your selected payment method.",
                      additionalInfo: "Please change your default payment method or add a new one."),
    "card_assoc_outstanding_balance":
        UberErrorInfo(errorInfo: "Sorry for the inconvenience - Your Uber card is associated with an Uber account that has                          outstanding balances.",
                      additionalInfo: "Please change your default payment method or add a new one. If you receive this error again after changing your default payment method, please contact Uber Customer Support."),
    "pay_balance":
        UberErrorInfo(errorInfo: "Sorry for the inconvenience - Your Uber account has an outstanding balance.",
                      additionalInfo: "Please change your default payment method or add a new one. If you receive this error again after changing your default payment method, please update your account settings within the Uber app or by visiting https://riders.uber.com"),
    "missing_payment_method":
        UberErrorInfo(errorInfo: "Sorry for the inconvenience - Your Uber account does not have a payment method on file.",
                      additionalInfo: "Please add a new payment method to your account.")]

class UberErrorInfo {
    
    /// Primary Uber Error description
    let errorInfo: String
    
    /// Additional Uber Error Info
    let additionalInfo: String
    
    init(errorInfo: String, additionalInfo: String) {
        self.errorInfo = errorInfo
        self.additionalInfo = additionalInfo
    }
}
