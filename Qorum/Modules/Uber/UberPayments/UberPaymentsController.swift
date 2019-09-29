//
//  UberPaymentsController.swift
//  Qorum
//
//  Created by Vadym Riznychok on 3/13/18.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit
import SwiftyJSON

final class UberPaymentMethod: NSObject {
    let paymentId: String
    let type: String
    let details: String
    
    init(paymentId: String, type: String, details: String) {
        self.paymentId = paymentId
        self.type = type
        self.details = details
    }
}

extension UberPaymentMethod: JSONAbleType {

    static func from(json: JSON) throws -> UberPaymentMethod {
        let paymentId = json["payment_method_id"].stringValue
        let type = json["type"].stringValue
        let details = json["description"].stringValue
        return UberPaymentMethod(paymentId: paymentId, type: type, details: details)
    }
    
}

class UberPaymentsController: BaseViewController, SBInstantiable {
    static let storyboardName = StoryboardName.uberOrder
    
    @IBOutlet weak var errorInfoLabel: UILabel!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    let refreshHeader = RefreshHeaderView()
    var freeRideAvailable = false
    var paymentMethods: [UberPaymentMethod] = []
    var uberPaymentError: String?
    var uberPaymentErrorCode: String?
    var lastUsedPaymentID: String?
    var selectedPaymentID: String? {
        didSet {
            UserDefaults.standard.set(selectedPaymentID, forKey: UserDefaultsKeys.defaultUberPaymentKey.rawValue)
        }
    }
    var isLoading = false
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRefresh()
        loadPayments()
        Notification.Name.UIApplicationDidBecomeActive
            .add(observer: self, selector: #selector(loadPaymentsWhenActive))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupInfo()
    }
    
    func setupRefresh() {
        refreshHeader.add(to: tableView, addingTarget: self, action: #selector(loadPayments))
    }
    
    func setupInfo() {
//        guard let errorInfo = kUberPaymentErrorCodesList[uberPaymentErrorCode!] else { return }
        guard let errorInfo = kUberPaymentErrorCodesList["pay_balance"] else { return }
        
        // Error title setup
        var errorTitle = errorInfo.errorInfo
        if uberPaymentError!.contains("Apple Pay"), uberPaymentErrorCode == "invalid_payment" {
            errorTitle = "Sorry for the inconvenience - Uber doesn't accept Apple Pay through Qorum."
        }
        
        errorInfoLabel.text = errorTitle
        
        // Error details setup
        infoTextView.text = errorInfo.additionalInfo
        infoTextView.contentMode = .center
        infoTextView.textAlignment = .center
        infoTextView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        infoTextView.font = UIFont.systemFont(ofSize: 14)
        
        guard errorInfo.additionalInfo.contains("Uber Customer Support") || errorInfo.additionalInfo.contains("https://riders.uber.com") else {
            return
        }
        
        let attributedString = NSMutableAttributedString(string: errorInfo.additionalInfo)
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        attributedString.setAttributes([.font: UIFont.systemFont(ofSize: 14),
                                        .foregroundColor: UIColor.searchBarBlack.withAlphaComponent(1),
                                        .paragraphStyle: style],
                                       range: (errorInfo.additionalInfo as NSString).range(of: errorInfo.additionalInfo))
        
        if errorInfo.additionalInfo.contains("Uber Customer Support") {
            let linkAttributes: [NSAttributedStringKey : Any] = [.link: URL(string: "https://help.uber.com/")!,
                                                                 .foregroundColor: UIColor.blue,
                                                                 .underlineStyle: 1]
                
            attributedString.addAttributes(linkAttributes,
                                           range: (errorInfo.additionalInfo as NSString).range(of: "Uber Customer Support"))
            
            infoTextView.attributedText = attributedString
            infoTextView.delegate = self
        } else if errorInfo.additionalInfo.contains("https://riders.uber.com") {
            let linkAttributes: [NSAttributedStringKey : Any] = [.link: URL(string: "https://riders.uber.com")!,
                                                                 .foregroundColor: UIColor.blue,
                                                                 .underlineStyle: 1]
            
            attributedString.setAttributes(linkAttributes,
                                           range: (errorInfo.additionalInfo as NSString).range(of: "https://riders.uber.com"))
            
            infoTextView.attributedText = attributedString
            infoTextView.delegate = self
        }
    }
    
    func popBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func loadPaymentsWhenActive() {
        guard isLoading == false else { return }
        
        isLoading = true
        refreshHeader.startAnimating()
        UberOrderInteractor().loadUberPayments { (success, methods, lastPaymentID) in
            self.isLoading = false
            self.refreshHeader.stopAnimating()
            if success == true, methods != nil {
                if var methodsToSort = methods,
                    let failedMethodIndex = methods?.index(where: { $0.paymentId == self.lastUsedPaymentID }) {
                    methodsToSort.g_moveToFirst(failedMethodIndex)
                    self.paymentMethods = methodsToSort
                } else {
                    self.paymentMethods = methods!
                }
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func loadPayments() {
        guard isLoading == false else { return }
        
        isLoading = true
        refreshHeader.startAnimating()
        UberOrderInteractor().loadUberPayments { (success, methods, lastPaymentID) in
            self.isLoading = false
            self.refreshHeader.stopAnimating()
            if success == true, methods != nil {
                self.lastUsedPaymentID = lastPaymentID
                if var methodsToSort = methods,
                    let failedMethodIndex = methods?.index(where: { $0.paymentId == self.lastUsedPaymentID }) {
                    methodsToSort.g_moveToFirst(failedMethodIndex)
                    self.paymentMethods = methodsToSort
                } else {
                    self.paymentMethods = methods!
                }
                self.tableView.reloadData()
            }
        }
    }

    @IBAction func addCardPressed() {
        var text = "You will be redirected to Uber app to add a new payment method. Please return to Qorum to redeem your free Uber ride."
        if freeRideAvailable == false {
            text = "You will be redirected to Uber app to add a new payment method. Please return to Qorum to request your Uber ride."
        }
        UIAlertController.presentAsAlert(title: "Add Card",
                                         message: text,
                                         actions: [
                                            ("Close", .default, { [weak self] in
                                                self?.popBack()
                                            } as () -> ()),
                                            ("Add card", .default, { [weak self] in
                                                self?.openUberApp()
                                            } as () -> ())
            ])
    }
    
    func openUberApp() {
        let app = UIApplication.shared
        if let uberURL = URL(string: "uber://"), app.canOpenURL(uberURL) {
            app.open(uberURL, options: [:], completionHandler: nil)
        } else if let appStoreURL = URL(string: "itms-apps://itunes.apple.com/us/app/uber/id368677368?mt=8") {
            app.open(appStoreURL, options: [:], completionHandler: nil)
        }
    }
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension UberPaymentsController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentMethods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UberPaymentCell") as? UberPaymentCell else {
            return UITableViewCell()
        }
        
        cell.fill(with: paymentMethods[indexPath.row],
                  isFailed: lastUsedPaymentID == paymentMethods[indexPath.row].paymentId)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? UberPaymentCell,
            cell.paymentMethod?.paymentId != lastUsedPaymentID else
        {
            return
        }
        
        selectedPaymentID = cell.paymentMethod?.paymentId
        popBack()
    }
    
}

// MARK: - UITextViewDelegate
extension UberPaymentsController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
    
}

class UberPaymentCell: UITableViewCell {
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var cardCode: UILabel!
    var paymentMethod: UberPaymentMethod?
    
    func fill(with method: UberPaymentMethod, isFailed: Bool) {
        paymentMethod = method
        cardCode.text = paymentMethod!.details
        cardImage.image = UIImage(named: "\(paymentMethod!.type)_card") ?? UIImage(named: "unknown_card")!
        
        if isFailed {
            contentView.alpha = 0.5
            let cardText = paymentMethod!.details
            let attributedString = NSMutableAttributedString(string: cardText)
            attributedString.addAttribute(NSAttributedStringKey.strikethroughStyle,
                                          value: 1,
                                          range: (attributedString.string as NSString).range(of: cardText))
            cardCode.attributedText = attributedString
        } else {
            contentView.alpha = 1
        }
    }
    
}
