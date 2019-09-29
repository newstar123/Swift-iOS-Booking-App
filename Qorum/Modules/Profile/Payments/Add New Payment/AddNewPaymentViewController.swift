//
//  AddNewPaymentViewController.swift
//  Qorum
//
//  Created by Stanislav on 04.12.2017.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit
import AVFoundation
import Stripe
import Moya

extension STPCardBrand {
    
    var image: UIImage {
        let brandName: String
        switch self {
        case .visa: brandName = "visa"
        case .masterCard: brandName = "mastercard"
        case .amex: brandName = "americanexpress"
        case .dinersClub: brandName = "dinersclub"
        case .discover: brandName = "discover"
        case .JCB: brandName = "jcb"
        // TODO: add image for Union Pay brand
        case .unionPay: brandName = "unknown"
        case .unknown: brandName = "unknown"
        }
        return UIImage(named: "\(brandName)_card") ?? UIImage(named: "unknown_card")!
    }
    
}

class AddNewPaymentViewController: BaseViewController, SBInstantiable, ScrollableInput {
    
    static let storyboardName = StoryboardName.profile
    
    var cardNumber = ""
    
    var cardBrand: STPCardBrand? {
        didSet {
            if cardBrand != oldValue {
                cardBrandIcon.image = cardBrand?.image
            }
        }
    }
    
    var cardExpiryDate = "" {
        didSet {
            let expArray = cardExpiryDate.components(separatedBy: " / ")
            if expArray.count == 2 {
                cardExpiryMonth = UInt(expArray[0])
                cardExpiryYear = UInt(expArray[1])
            } else {
                cardExpiryMonth = nil
                cardExpiryYear = nil
            }
        }
    }
    
    var cardExpiryMonth: UInt?
    var cardExpiryYear: UInt?
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var revealCardFormContainer: UIStackView!
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var cardExpiryTextField: UITextField!
    @IBOutlet weak var cardCVCTextField: UITextField!
    @IBOutlet weak var cardZipTextField: UITextField!
    @IBOutlet weak var cardBrandIcon: UIImageView!
    
    let addCardButton: UIButton = {
        let addCardButton = UIButton(type: .system)
        addCardButton.addTarget(self, action: #selector(addCardButtonPressed), for: .touchUpInside)
        addCardButton.tintColor = .white
        addCardButton.setTitle("ADD CARD", for: .normal)
        addCardButton.titleLabel?.font = UIFont.montserrat.medium(14)
        addCardButton.setImage(#imageLiteral(resourceName: "CreditCardIcon"), for: .normal)
        addCardButton.setBackgroundImage(#imageLiteral(resourceName: "background-button"), for: .normal)
        
        addCardButton.contentHorizontalAlignment = .left
        addCardButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        addCardButton.frame = CGRect(x: 0, y: 0, width: .deviceWidth, height: 44)
        addCardButton.setNeedsLayout()
        addCardButton.layoutIfNeeded()
        let titleWidth = addCardButton.titleLabel!.width
        let buttonWidth = addCardButton.width
        let iconWidth = addCardButton.imageView!.width
        let contentLeftPadding = addCardButton.contentEdgeInsets.left
        let titleLeftPadding = (buttonWidth-titleWidth)/2 - (contentLeftPadding+iconWidth)
        addCardButton.titleEdgeInsets = UIEdgeInsetsMake(0, titleLeftPadding, 0, 0)
        return addCardButton
    }()
    
    override var backgroundStyle: BaseViewController.BackgroundAppearance {
        return .empty
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Just add a fake blur here to get rid of flicker artifacts when going from/to the Payments scene @sshemiakov
        let fakeBlur = UIView.blurredBackground()
        fakeBlur.blurRadius = 0
        view.insertSubview(fakeBlur, at: 0)
        
        revealCardFormContainer.isHidden = true
        let textFields: [UITextField] = [cardExpiryTextField, cardCVCTextField, cardZipTextField]
        for textField in textFields {
            let localizedPlaceholder = NSLocalizedString(textField.placeholder ?? "", comment: "")
            textField.attributedPlaceholder = NSAttributedString(string: localizedPlaceholder,
                                                                 attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.6)])
        }
        let cardNumberLocalizedPlaceholder = NSLocalizedString(cardNumberTextField.placeholder ?? "", comment: "")
        cardNumberTextField.attributedPlaceholder = NSAttributedString(string: cardNumberLocalizedPlaceholder,
                                                                       attributes: [.foregroundColor: UIColor.white])
        for textField in [cardNumberTextField] + textFields {
            textField.inputAccessoryView = addCardButton
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObserver()
        updateAddCardButton()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeKeyboardObserver()
    }
    
    /// Manages Add Card Button Availability
    ///
    /// - Parameter zipCodeString: zipcode string value
    func updateAddCardButton(zipCodeString: String? = nil) {
        let isEnabled = cardNumber.isNotEmpty &&
            cardExpiryMonth.hasValue &&
            cardExpiryYear.hasValue &&
            cardCVCTextField.text.isNotNilNorEmpty &&
            (zipCodeString ?? cardZipTextField.text).isNotNilNorEmpty
        addCardButton.isEnabled = isEnabled
    }
    
    // MARK: - Actions
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cardNumberEditingDidBegin(_ sender: Any) {
        revealCardForm()
    }
    
    @IBAction func cardNumberEditingChanged(_ textField: UITextField) {
        let text = textField.text ?? ""
        let brand = STPCardValidator.brand(forNumber: text)
        let maxCount = STPCardValidator.maxLength(for: brand)
        let number = String(STPCardValidator.sanitizedNumericString(for: text).prefix(maxCount))
        cardBrand = number.count > 1 ? brand : nil
        let spacing: [Int]
        switch brand {
        case .amex, .dinersClub: spacing = [3, 9]
        case .unknown: spacing = []
        default: spacing = [3, 7, 11]
        }
        let keyValues = textField.defaultTextAttributes.lazy.map { (NSAttributedStringKey($0.key), $0.value) }
        let attributes = Dictionary(uniqueKeysWithValues: keyValues)
        let attributedString = NSMutableAttributedString(string: number, attributes: attributes)
        for i in 0 ..< attributedString.length {
            let kern = spacing.contains(i) ? 5 : 0
            attributedString.addAttribute(.kern, value: kern, range: NSMakeRange(i, 1))
        }
        textField.attributedText = attributedString
        if number.count > cardNumber.count, number.count == maxCount {
            cardExpiryTextField.becomeFirstResponder()
        }
        cardNumber = number
        updateAddCardButton()
    }
    
    @IBAction func cardExpiryEditingChanged(_ textField: UITextField) {
        let text = textField.text ?? ""
        if text.count > cardExpiryDate.count { // added value
            switch text.count {
            case 1 where text != "0" && text != "1":
                textField.text = "0\(text) / "
            case 2:
                let first = Int(text.prefix(1)) ?? 0
                let last = Int(text.suffix(1)) ?? 0
                if first > 0, last > 2 {
                    textField.text = "0\(text.dropLast()) / \(last)"
                } else {
                    textField.text = "\(text) / "
                }
            case 3:
                let prefix = text.prefix(2)
                let suffix = text.suffix(1)
                textField.text = "\(prefix) / \(suffix)"
            case 7:
                cardCVCTextField.becomeFirstResponder()
            case 8...:
                textField.text = String(text.prefix(7))
            default: break
            }
        } else { // removed value
            if text.count == 4 {
                textField.text = String(text.prefix(2))
            }
        }
        cardExpiryDate = textField.text ?? ""
        updateAddCardButton()
    }
    
    @IBAction func cardCVCEditingChanged(_ textField: UITextField) {
        updateAddCardButton()
        let text = textField.text ?? ""
        let cvc = STPCardValidator.sanitizedNumericString(for: text)
        textField.text = cvc
        let maxCount = STPCardValidator.maxCVCLength(for: cardBrand ?? .unknown)
        if cvc.count == maxCount {
            cardZipTextField.becomeFirstResponder()
        }
    }
    
    @objc func addCardButtonPressed() {
        if  let cardExpiryMonth = cardExpiryMonth,
            let cardExpiryYear = cardExpiryYear,
            let cardCVC = cardCVCTextField.text
        {
            let cardZip = cardZipTextField.text ?? ""
            let creditCardInfo = CreditCardInfo(number: cardNumber,
                                                expiryMonth: cardExpiryMonth,
                                                expiryYear: cardExpiryYear,
                                                cvv: cardCVC,
                                                zip: cardZip)
            getStripeToken(creditCardInfo: creditCardInfo)
        }
    }
    
    @IBAction func scanCardButtonPressed(_ sender: Any) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async { [unowned self] in
                if granted {
                    let scanViewController = CardIOPaymentViewController(paymentDelegate: self)!
                    scanViewController.disableManualEntryButtons = true
                    scanViewController.hideCardIOLogo = true
                    scanViewController.collectExpiry = false
                    scanViewController.collectCVV = false
                    scanViewController.suppressScanConfirmation = true
                    self.present(scanViewController, animated: true, completion: nil)
                } else {
                    UIAlertController.presentAsAlert(title: "Camera Permissions", message: "We need to use your camera to scan your credit card. Please allow permissions from the app settings.")
                }
            }
        }
    }
    
    // MARK: - Internal
    
    /// Enables card form
    fileprivate func revealCardForm() {
        let cardNumberLocalizedPlaceholder = NSLocalizedString(cardNumberTextField.placeholder ?? "", comment: "")
        cardNumberTextField.attributedPlaceholder = NSAttributedString(string: cardNumberLocalizedPlaceholder,
                                                                       attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.6)])
        revealCardFormContainer.isHidden = false
    }
    
    //MARK: - ScrollableInput
    
    @objc func inputChanged(_ notification: Notification) {
        update(scrollView: scrollView, with: notification.userInfo)
    }
    
    // MARK: - Stripe
    
    /// Requests STRIPE token based on credit card info
    ///
    /// - Parameter creditCardInfo: credit card data
    private func getStripeToken(creditCardInfo: CreditCardInfo) {
        let cardParams = STPCardParams()
        cardParams.name = [User.stored.firstName, User.stored.lastName].compactMap({ $0?.uppercased() }).joined(separator: " ")
        cardParams.number = creditCardInfo.number
        cardParams.expMonth = creditCardInfo.expiryMonth
        cardParams.expYear = creditCardInfo.expiryYear
        cardParams.cvc = creditCardInfo.cvv
        cardParams.address.postalCode = creditCardInfo.zip
        
        showLoader()
        STPAPIClient.shared().createToken(withCard: cardParams) { [weak self] (token, error) in
            if let tokenId = token?.tokenId {
                self?.addStripeTokenToUserProfile(tokenId: tokenId, cardInfo: creditCardInfo) { [weak self] result in
                    self?.hideLoader()
                    switch result {
                    case let .value(cardDict):
                        print("addStripeTokenToUserProfile response:", cardDict)
                        self?.navigationController?.popViewController(animated: true)
                    case let .error(error):
                        print("addStripeTokenToUserProfile error:", error)
                        UIAlertController.presentAsAlert(title: "Card Upload Error",
                                                         message: "There was a problem sending your card data safely. Please try again later.")
                    }
                }
            } else if let error = error {
                self?.hideLoader()
                UIAlertController.presentAsAlert(title: "Card Upload Error", message: error.localizedDescription)
            } else {
                self?.hideLoader(showing: .error)
                print("STPAPIClient.createToken unexpected error!")
            }
        }
    }
    
    /// Submits received credit card token to Qorum server
    ///
    /// - Parameters:
    ///   - tokenId: credit card token from STRIPE
    ///   - cardInfo: credit card data
    ///   - completion: completion handler
    private func addStripeTokenToUserProfile(tokenId: String,
                                             cardInfo: CreditCardInfo,
                                             completion: @escaping APIHandler<[String: Any]>) {
        guard !User.stored.isGuest else {
            completion(.error("Invalid user"))
            return
        }
        let request = AuthenticatedRequest(target: .addPaymentCard(userId: User.stored.userId, stripeToken: tokenId, zip: cardInfo.zip))
        request.perform { response in
            switch response.result {
            case let .value(json):
                do {
                    let dict = try json.expectingDictionary()
                    completion(.value(dict))
                } catch {
                    completion(.error(error))
                }
            case let .error(error):
                completion(.error(error))
            }
        }
    }
    
}

// MARK: - CardIOPaymentViewControllerDelegate
extension AddNewPaymentViewController: CardIOPaymentViewControllerDelegate {
    
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!,
                        in paymentViewController: CardIOPaymentViewController!) {
        revealCardForm()
        cardNumberTextField.text = cardInfo.cardNumber
        cardNumberEditingChanged(cardNumberTextField)
        cardExpiryTextField.becomeFirstResponder()
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UITextFieldDelegate
extension AddNewPaymentViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let newString: String? = (textField.text! as NSString).replacingCharacters(in: range, with: string)
//        let isEnabled = cardNumber.isNotEmpty &&
//            cardExpiryMonth.hasValue &&
//            cardExpiryYear.hasValue &&
//            cardCVCTextField.text.isNotNilNorEmpty &&
//            newString.isNotNilNorEmpty
//        addCardButton.isEnabled = isEnabled

        updateAddCardButton(zipCodeString: newString)
        return true
    }
}
