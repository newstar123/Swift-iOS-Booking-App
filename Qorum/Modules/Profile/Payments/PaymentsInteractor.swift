//
//  PaymentsInteractor.swift
//  Qorum
//
//  Created by Dima Tsurkan on 11/27/17.
//  Copyright (c) 2017 Bizico. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol PaymentsBusinessLogic {
    
    /// Performs action with request
    ///
    /// - Parameter request: request model
    func action(request: Payments.Request)
}

protocol PaymentsDataStore {
    var cards: [CreditCard] { get set }
}

class PaymentsInteractor: PaymentsDataStore {
    var presenter: PaymentsPresentationLogic?
    private(set) lazy var worker = PaymentsWorker()
    var cards: [CreditCard] = []
}

// MARK: - PaymentsBusinessLogic
extension PaymentsInteractor: PaymentsBusinessLogic {
    
    func action(request: Payments.Request) {
        switch request {
        case .fetchCards:
            presenter?.present(loadingState: .started)
            worker.fetchPaymentCards { [weak self] result in
                self?.presenter?.present(response: result)
            }
        case .setDefaultPayment(let payment):
            switch payment {
            case .applePay:
                // TODO: - add ApplePay support?
                break
            case .card(let card):
                presenter?.present(loadingState: .started)
                worker.setDefaultCard(withId: card.id) { [weak self] result in
                    switch result {
                    case .value:
                        self?.action(request: .fetchCards)
                    case let .error(error):
                        self?.presenter?.present(response: .error(error))
                    }
                }
            }
        case .deleteCard(let card):
            presenter?.present(loadingState: .started)
            worker.deleteCard(withId: card.id) { [weak self] result in
                switch result {
                case let .value(any):
                    print("PaymentsInteractor deleteCard value:", any)
                    self?.action(request: .fetchCards)
                case let .error(error):
                    self?.presenter?.present(loadingState: .finished)
                    self?.presenter?.presentAlert(title: "Card Delete Error",
                                                  message: "There was a problem deleting your card. Please try again later.")
                    print("PaymentsInteractor deleteCard error:", error)
                }
            }
        }
    }
    
}