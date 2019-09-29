//
//  AddNewPaymentMethodViewController.swift
//  Qorum
//
//  Created by Dima Tsurkan on 11/27/17.
//  Copyright © 2017 Dima Tsurkan. All rights reserved.
//

import UIKit
import Eureka
import CreditCardRow
import Stripe
import KRProgressHUD
import Moya

class AddNewPaymentMethodViewController: FormViewController, SBInstantiable {
    
    static var storyboardName = StoryboardName.profile
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CreditCardRow.defaultRowInitializer = {
          $0.cellProvider = CellProvider<CreditCardCell>(nibName: "QorumCreditCardRow", bundle: nil)
        }
        
        form +++ Section()
        form +++ Section() { section in
                section.header = nil
                section.footer = nil
            
            }
            
            <<< QorumCreditCardRow("Credit Card")
                .cellSetup({ (cell, row) in
                    cell.height = { CGFloat(108) }()
                    
//                    cell.numberField.isHidden = true
//                    cell.baseRow.baseCell.contentView.backgroundColor = .red
                    
//                    cell.baseRow.baseCell.layer.borderWidth = 0
//                    cell.baseRow.baseCell.layer.borderColor = UIColor.green.cgColor
                    
                    cell.baseRow.baseCell.contentView.layer.borderWidth = 5
                    cell.baseRow.baseCell.contentView.layer.borderColor = UIColor.green.cgColor
                    
                })
            
            <<< ZipCodeRow("Zip") { row in
                let placehholderStr = NSAttributedString(string: "Zip", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightText])
                row.baseCell.backgroundColor = .clear
                row.baseCell.backgroundView?.backgroundColor = .clear
                row.cell.textField.attributedPlaceholder = placehholderStr
                row.cell.textLabel?.textColor = .white
            }
        
        
        form +++ Section()
            <<< ButtonRow { row in
                row.title = "ADD CARD"
                row.baseCell.backgroundColor = .red
            }
            .onCellSelection { (cell, row) in
                self.addCardButtonPressed()
            }
        
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        
    }
    
    // MARK: - Actions
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Internal
    
    private func configureView() {
        addCityBackground()
        self.navigationItem.title = ""
        self.navigationItem.leftBarButtonItem = nil
        self.tableView.backgroundColor = .clear
    }
    
    private func addCardButtonPressed() {
        if let creditCardRow = form.rowBy(tag: "Credit Card") as? CreditCardRow {
            let cardNumber = creditCardRow.value?.creditCardNumber ?? ""
            
            let exp = creditCardRow.value?.expiration ?? ""
            let expArray = exp.components(separatedBy: "/")
            
            if expArray.count == 2 {
                let expMonth = expArray[0]
                let expYear = expArray[1]
                
                let cvv = creditCardRow.value?.cvv ?? ""
                let formValues = form.values()
                let zip = formValues["Zip"] as? String ?? ""
                
                let creditCardInfo = CreditCardInfo(number: cardNumber, expiryMonth: UInt(expMonth)!, expiryYear: UInt(expYear)!, cvv: cvv, zip: zip)
                getStripeToken(creditCardInfo: creditCardInfo)
            }            
        }
    }
    
    private func getStripeToken(creditCardInfo: CreditCardInfo) {
        showLoader()
        let cardParams = STPCardParams()
        cardParams.name = "\(String(describing: User.stored?.firstName)) \(String(describing: User.stored?.lastName))"
        cardParams.number = creditCardInfo.number
        cardParams.expMonth = creditCardInfo.expiryMonth
        cardParams.expYear = creditCardInfo.expiryYear
        cardParams.cvc = creditCardInfo.cvv
        
        
        STPAPIClient.shared().createToken(withCard: cardParams) { (token, error) in
            if error != nil {
                self.hideLoader()
                debugPrint("error: \(error)")
            } else {
                self.addStripeTokenToUserProfile(token: (token?.tokenId)!, cardInfo: creditCardInfo)
            }
        }
    }
    
    private func addStripeTokenToUserProfile(token: String, cardInfo: CreditCardInfo) {
        let provider = MoyaProvider<QorumAuthenticatedAPI>.headerTypeProvider //(endpointClosure: endpointClosure)
        let user = User.stored ?? User.guestUser
        provider.request(.addPaymentCard(userId: user.userId, stripeToken: token, zip: cardInfo.zip)) { (result) in
            switch result {
            case let .success(moyaResponse):
                do {
                    let data = moyaResponse.data
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
                    
                    debugPrint("addStripeTokenToUserProfile.JSON: \(json)")
                } catch let error {
                    debugPrint("addStripeTokenToUserProfile.ERROR: \(error)")
                }
            case let .failure(error):
                debugPrint("addStripeTokenToUserProfile.ERROR: \(error)")
            }
        }
    }
    
    private func showLoader() {
        KRProgressHUD.appearance().style = .black
        KRProgressHUD.show()
    }
    
    private func hideLoader() {
        KRProgressHUD.dismiss()
    }
    
}
