//
//  BillContentViewController.swift
//  Qorum
//
//  Created by Sergey Sivak on 2/12/18.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

protocol TipsDelegate: AnyObject {
    
    var billTotalAmount: Float? { get }
    
    func didSelect(tip: BillModels.Tip)
    
    func didStartCustomChoiceTipsEditing()
    
    func didCancelCustomChoiceTipsEditing()
}

class BillContentViewController: UIViewController {
    
    @IBOutlet private weak var subtotal: UILabel!
    
    @IBOutlet private weak var subtotalScrollTopButton: UIButton!
    
    @IBOutlet private weak var subtotalScrollBottomButton: UIButton!
    
    @IBOutlet private weak var subtotalTableView: UITableView!
    
    @IBOutlet private weak var tipSelectionOverlay: UIView!
    
    @IBOutlet private weak var tipSelectionXConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var totalBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var summaryTip: UILabel!
    
    @IBOutlet private weak var discountPercent: UILabel!
    
    @IBOutlet private weak var summaryDiscount: UILabel!
    
    @IBOutlet private weak var summaryTax: UILabel!
    
    @IBOutlet private weak var summaryTotal: UILabel!
    
    @IBOutlet private weak var summaryFreeDrinks: UILabel!
    
    @IBOutlet private weak var sectionFreeDrinks: UIView!
    
    @IBOutlet private weak var tipsView: UIView!
    
    @IBOutlet private weak var customTipsField: UITextField!
    
    @IBOutlet private weak var customTipsConfirm: UIButton!
    
    @IBOutlet private var tipsChoiceViews: [UIControl]!
    
    private let tips = [.percents(18), .percents(20), .percents(25), .cents(0)] as [BillModels.Tip]
    
    private var selectedTip: BillModels.Tip = .percents(18)
    
    private var bill: Bill? {
        didSet { view.isHidden = bill == nil }
    }
    
    private var billItems: [BillItem] = []
    
    internal weak var delegate: TipsDelegate?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bill = nil
        subtotalScrollBottomButton.transform = CGAffineTransform(rotationAngle: .pi)
        configureTipsViews()
        customTipsField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Notification.Name.UIKeyboardDidShow.addObserver { [weak self] notification in
            guard let welf = self else { return }
            if var rect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                rect = welf.view.convert(rect, from: .none)
                welf.totalBottomConstraint.constant = welf.view.frame.height - rect.origin.y
                UIView.animate(withDuration: 0.25) { [weak self] in
                    self?.view.layoutIfNeeded()
                }
            }
        }
        Notification.Name.UIKeyboardWillHide.addObserver { [weak self] notification in
            self?.totalBottomConstraint.constant = 0
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: -
    
    private func configureTipsViews() {
        tipsView.cornerRadius = 17
        tipSelectionOverlay.cornerRadius = 17
        customTipsConfirm.frame = CGRect(x: 0, y: 0, width: .deviceWidth, height: 51)
        customTipsField.inputAccessoryView = customTipsConfirm
    }
    
    private func updateScrollIndicators() {
        let isScrollable = subtotalTableView.contentSize.height > subtotalTableView.height
        subtotalScrollTopButton.isHidden = !isScrollable || subtotalTableView.contentOffset.y <= 0
        subtotalScrollBottomButton.isHidden = !isScrollable || subtotalTableView.contentOffset.y >= subtotalTableView.contentSize.height - subtotalTableView.height
    }
    
    internal func update(with bill: Bill) {
        self.bill = bill
        self.billItems = []
        bill.items.forEach { (new) in
            if let found = billItems.index(where: { $0.isMergable(with: new) }) {
                try! billItems[found].merge(with: new)
            } else {
                billItems.append(new)
            }
        }
        
        // summary
        summaryTip.text = "$\(bill.gratuityPrice.monetaryValue)"
        discountPercent.text = "Qorum - \(bill.discount)% *:"
        summaryDiscount.text = "-$\(bill.discountPrice.monetaryValue)"
        summaryTax.text = "$\(bill.taxPrice.monetaryValue)"
        summaryTotal.text = "$\(bill.totalPrice.monetaryValue)"
        summaryFreeDrinks.text = "-$\(bill.totals.freeDrinksPrice.monetaryValue)"
        sectionFreeDrinks.isHidden = bill.totals.freeDrinks < 1
        
        // subtotal
        subtotal.text = "$\(bill.totals.subTotal.monetaryValue)"
        subtotalTableView.reloadData()
        
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.view.layoutIfNeeded()
        }
        
        // tips
        
        if bill.exactGratuity == nil && tips.contains(.percents(bill.gratuity)) {
            select(.percents(bill.gratuity))
            customTipsField.text = "Custom"
        } else {
            select(.cents(bill.exactGratuity ?? 0))
            customTipsField.text = "$\(bill.gratuityPrice.monetaryValue)"
        }
        tipsView.isHidden = delegate?.billTotalAmount == .none
        updateScrollIndicators()
    }
    
    @IBAction internal func tipsChoiceSelected(_ sender: UIView) {
        let array = Array(zip(self.tipsChoiceViews!, self.tips))
        guard let newTip = array.first(where: { $0.0 == sender })?.1 else { return }
        if newTip == selectedTip {
            return
        }
        selectedTip = newTip
        switch newTip {
        case .percents(let percents):
            if customTipsField.isFirstResponder {
                customTipsField.resignFirstResponder()
                delegate?.didCancelCustomChoiceTipsEditing()
            }
            customTipsField.text = "Custom"
            select(newTip) { [weak bill, weak delegate] in
                if percents != bill?.gratuity {
                    delegate?.didSelect(tip: newTip)
                }
            }
        case .cents:
            select(newTip) { [weak customTipsField, weak delegate] in
                customTipsField?.becomeFirstResponder()
                delegate?.didStartCustomChoiceTipsEditing()
            }
        }
    }
    
    @IBAction func subtotalScrollTopButtonPressed(_ sender: Any) {
        subtotalTableView.scrollToTop(animated: true)
    }
    
    @IBAction func subtotalScrollBottomButtonPressed(_ sender: Any) {
        subtotalTableView.scrollToBottom(animated: true)
    }

    /// Selects custom or fixed tips value with animation
    ///
    /// - Parameters:
    ///   - tip: tips amount
    ///   - onFinish: animation completion block
    private func select(_ tip: BillModels.Tip,
                        completion onFinish: (() -> ())? = nil) {
        let viewToSelect: UIControl
        if tip.isCustom {
            viewToSelect = customTipsField
        } else {
            let array = Array(zip(tipsChoiceViews!, tips))
            guard let buttonToSelect = array.first(where: { $0.1 == tip })?.0 else { return }
            viewToSelect = buttonToSelect
        }
        let destinationX = viewToSelect.frame.minX
        let kBounce = 10
        tipsView.isUserInteractionEnabled = false
        let delta = (destinationX - tipSelectionOverlay.frame.minX) / 100 * CGFloat(kBounce)
        self.tipSelectionXConstraint.constant = destinationX + delta
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let self = self else { return }
            for button in self.tipsChoiceViews.compactMap({ $0 as? UIButton }) {
                if button == viewToSelect {
                    button.titleLabel?.font = UIFont.montserrat.semibold(14)
                } else {
                    button.titleLabel?.font = UIFont.montserrat.regular(14)
                }
            }
            if tip.isCustom {
                self.customTipsField.font = UIFont.montserrat.semibold(14)
            } else {
                self.customTipsField.font = UIFont.montserrat.regular(14)
            }
            self.tipsView.layoutIfNeeded()
        }, completion: { [weak self] _ in
            self?.tipSelectionXConstraint.constant = destinationX
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                self?.tipsView.layoutIfNeeded()
                }, completion: { [weak self] _ in
                    self?.tipsView.isUserInteractionEnabled = true
                    onFinish?()
            })
        })
    }
    
    @IBAction private func customTipsTextDidChange() {
        var text = customTipsField.text ?? ""
        if text.isNotEmpty && !text.starts(with: "$") {
            text = "$" + text
            customTipsField.text = text
        }
        
        let string = text
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: ".") // localized dot-safe text
        let amount = Float(string) ?? 0
        customTipsConfirm.isEnabled = amount >= kTipsMinAmount
    }
    
    @IBAction private func confirmFixedChoice(_ sender: UIView) {
        let amountText = (customTipsField.text ?? "")
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: ".") // localized dot-safe text
        if let dollars = Double(amountText) {
            customTipsField.resignFirstResponder()
            let cents = Int(Money(dollars, .dollars)[in: .cents])
            if cents != bill?.exactGratuity {
                delegate?.didSelect(tip: .cents(cents))
            }
        }
    }
    
}

// MARK: - UITextFieldDelegate
extension BillContentViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let isCustomSelected = selectedTip.isCustom
        if !isCustomSelected {
            tipsChoiceSelected(textField)
        }
        return isCustomSelected
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "Custom" {
            textField.text = "$"
        }
        customTipsTextDidChange()
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        let newText = text
            .replacingCharacters(in: Range(range, in: text)!, with: string)
            .replacingOccurrences(of: ",", with: ".") // localized dot-safe text
        let regex = try! NSRegularExpression(pattern: "^\\$?(0[0-9]?\\.[0-9]{0,2}|0|[1-9][0-9]*(\\.[0-9]{0,2})?)?$")
        var isValid = regex.numberOfMatches(in: newText, range: NSRange(location: 0, length: newText.count)) == 1
        if isValid {
            let string = newText.replacingOccurrences(of: "$", with: "")
            if let float = Float(string), float > kTipsMaxAmount {
                isValid = false
            }
        }
        return isValid
    }
    
}

// MARK: - UITableViewDataSource
extension BillContentViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(1, billItems.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch billItems.count {
        case let qty where qty > 0:
            let item = billItems[indexPath.row]
            cell = tableView.dequeueReusableCell(withIdentifier: "billItemCellIdentifier", for: indexPath)
            (cell.viewWithTag(1) as? UILabel)?.text = item.name
            (cell.viewWithTag(2) as? UILabel)?.text = "\(item.quantity)x"
            (cell.viewWithTag(3) as? UILabel)?.text = "$\(item.totalPrice.monetaryValue)"
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "noItemsCellIdentifier", for: indexPath)
            (cell.viewWithTag(1) as? UILabel)?.text = "Nothing ordered yet..."
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension BillContentViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateScrollIndicators()
    }
    
}
