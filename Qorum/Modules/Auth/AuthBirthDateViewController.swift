//
//  AuthBirthDateViewController.swift
//  Qorum
//
//  Created by Stanislav on 06.12.2017.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit

class AuthBirthDateViewController: BaseViewController, SBInstantiable, ScrollableInput {
    
    static let storyboardName = StoryboardName.auth
    
    private(set) lazy var birthDatePicker: BirthdayPicker = {
        let picker = BirthdayPicker()
        picker.formatter = Date.checkAgeFormatter
        let now = Date()
        picker.datePickerMode = .date
        picker.timeZone = .utc
        picker.date = { () -> Date? in
            var components = DateComponents()
            components.year = -21
            let date = Calendar.current.date(byAdding: components, to: now)
            
            return date
        }() ?? now
        picker.minimumDate = { () -> Date? in
            var components = DateComponents()
            components.year = -100
            let date = Calendar.current.date(byAdding: components, to: now)
            
            return date
            }() ?? now
        picker.maximumDate = {
            return now
        }()
        picker.addTarget(self, action: #selector(birthdayPickerDidChange), for: .valueChanged)
        return picker
    }()
    
    var age: Int {
        let ageComponents = Calendar.current.dateComponents([.year], from: birthDatePicker.date, to: Date())
        return ageComponents.year ?? 0
    }
    
    private let placeholder: String = "MM DD YYYY"
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet private weak var birthDateTextField: UITextField!
    
    override var backgroundStyle: BaseViewController.BackgroundAppearance {
        return .empty
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        birthDatePicker.textField = birthDateTextField
        birthDateTextField.applyToolbar()
        let string = placeholder
        birthDateTextField.attributedPlaceholder = dateAttributedString(from: string, color: .white)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeKeyboardObserver()
    }
    
    // MARK: - Actions
    
    
    @objc private func birthdayPickerDidChange() {
        let string = birthDatePicker.formatter.string(from: birthDatePicker.date)
        birthDateTextField.attributedText = dateAttributedString(from: string, color: .white)
    }
    
    /*
     * Forms date attributed string.
     * Parameter:
     * -string: source string
     * -color: string font color
     */
    private func dateAttributedString(from string: String, color: UIColor) -> NSAttributedString {
        let components = string.components(separatedBy: " ")
        let attributedText = NSMutableAttributedString(
            (components[0],   UIFont.montserrat.medium(22), color),
            ("    /    ", UIFont.montserrat.regular(22), color),
            (components[1],   UIFont.montserrat.medium(22), color),
            ("    /    ", UIFont.montserrat.regular(22), color),
            (components[2],   UIFont.montserrat.medium(22), color)
        )
        
        return attributedText
    }
    
    /*
     * Checks input successfull age check flow.
     */
    @IBAction func letMeInButtonPressed(_ sender: Any) {
        guard birthDateTextField.text.isNotNilNorEmpty else {
            let message = "Please, choose you birth date"
            let action: UIAlertController.CustomAction
            action = ("Okay", .cancel, { [weak self] in
                self?.birthDateTextField.becomeFirstResponder()
            })
            UIAlertController.presentAsAlert(message: message,
                                             actions: [action])
            return
        }
        if age >= 21 {
            exit()
        } else {
            let ageMessage = "We're sorry, but you're not allowed to use Qorum until you are of legal drinking age."
            UIAlertController.presentAsAlert(message: ageMessage,
                                             actions: [(title: "Okay", style: .cancel, handler: nil)])
        }
    }
    
    /*
     * Completes successfull age check flow.
     */
    func exit() {
        AnalyticsService.shared.track(event: MixpanelEvents.submit21BDay.rawValue)
        UserDefaults.standard.set(true, for: .didShowAgeGatingKey)
        navigationController?.popViewController(animated: false)
    }
    
    // MARK: - ScrollableInput
    
    @objc func inputChanged(_ notification: Notification) {
        update(scrollView: scrollView, with: notification.userInfo)
    }
    
    // MARK: - Misc
    
    /// Disaple copy/cut/paste by hiding the menu
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if birthDateTextField.isFirstResponder {
            OperationQueue.main.addOperation {
                UIMenuController.shared.setMenuVisible(false, animated: false)
            }
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
