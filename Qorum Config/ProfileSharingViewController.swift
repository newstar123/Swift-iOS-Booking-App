//
//  ProfileSharingViewController.swift
//  Qorum Config
//
//  Created by Stanislav on 18.09.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

/// Contoroller for creating/editing/sharing configuration profile in a JSON format
class ProfileSharingViewController: UIViewController {
    
    /// TextView for editing profile
    let textView = UITextView()
    /// Contains Copy, Paste, Clear buttons
    let buttonsStack = UIStackView()
    /// Button for copying text from the textView
    let copyButton = UIButton(type: .system)
    /// Button for pasting text to the textView
    let pasteButton = UIButton(type: .system)
    /// Button for cleaning text from the textView
    let clearButton = UIButton(type: .system)
    
    
    
    //MARK: - Configuring view
    
    fileprivate func configureTextView() {
        textView.layer.cornerRadius = 4
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        textView.text = (ConfigProfile.currentStored ?? ConfigProfile.currentUntitled!).jsonString()
        textView.delegate = self
        view.addSubview(textView)
    }
    
    fileprivate func configureButtonsStack() {
        copyButton.setTitle("Copy", for: [])
        copyButton.addTarget(self, action: #selector(copyButtonDidTap), for: .touchUpInside)
        pasteButton.setTitle("Paste", for: [])
        pasteButton.addTarget(self, action: #selector(pasteButtonDidTap), for: .touchUpInside)
        clearButton.setTitle("Clear", for: [])
        clearButton.addTarget(self, action: #selector(clearButtonDidTap), for: .touchUpInside)
        buttonsStack.axis = .horizontal
        buttonsStack.distribution = .fillEqually
        buttonsStack.spacing = 16
        buttonsStack.addArrangedSubview(copyButton)
        buttonsStack.addArrangedSubview(pasteButton)
        buttonsStack.addArrangedSubview(clearButton)
        view.addSubview(buttonsStack)
        
        updateButtons()
    }
    
    fileprivate func configureApplyButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Apply",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(apply))
        updateApplyButton()
    }
    
    fileprivate func configureView() {
        view.backgroundColor = .white
        configureTextView()
        configureButtonsStack()
        configureApplyButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    fileprivate func configurePadding() {
        let padding: CGFloat = 16
        let width = view.bounds.width - padding*2
        let buttonsY = topLayoutGuide.length + padding/2
        let buttonsHeight: CGFloat = 26
        let textViewY = buttonsY + buttonsHeight + padding/2
        buttonsStack.frame = CGRect(x: padding, y: buttonsY, width: width, height: buttonsHeight)
        textView.frame = CGRect(x: padding, y: textViewY, width: width, height: 250)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configurePadding()
    }
    
    
    
    
    //MARK: - Internal
    
    /// Applies configuration according to the JSON string in the textView if available
    @objc func apply() {
        guard let profile = parsedProfile else { return }
        if profile.isAlreadyStored {
            profile.apply()
            updateApplyButton()
        } else {
            let addingAlert = AddingAlert(saving: profile) { [weak self] added in
                if added {
                    self?.updateApplyButton()
                }
            }
            present(addingAlert, animated: true, completion: nil)
        }
    }
    
    /// Copies the text from the textView to the clipboard
    @objc func copyButtonDidTap() {
        UIPasteboard.general.string = textView.text
    }
    
    /// Inserts the text from the clipboard to the textView and updates the view
    @objc func pasteButtonDidTap() {
        if let pasteString = UIPasteboard.general.string {
            textView.text = pasteString
            updateApplyButton()
            updateButtons()
        }
    }
    
    /// Cleans textView and updates the view
    @objc func clearButtonDidTap() {
        textView.text = ""
        navigationItem.rightBarButtonItem?.isEnabled = false
        updateButtons()
    }
    
    /// Updates buttons states according to the textView's state
    fileprivate func updateButtons() {
        let text = textView.text ?? ""
        copyButton.isEnabled = !text.isEmpty
        clearButton.isEnabled = !text.isEmpty
    }
    
    /// Tries to decode JSON string from the textView to the ConfigProfile
    ///
    /// Returns nil if decoding fails
    fileprivate var parsedProfile: ConfigProfile? {
        guard let text = textView.text else { return nil }
        return try? ConfigProfile.from(jsonString: text)
    }
    
    /// Updates apply button state and title
    fileprivate func updateApplyButton() {
        let state = applyButtonState
        navigationItem.rightBarButtonItem?.isEnabled = state.isEnabled
        navigationItem.rightBarButtonItem?.title = state.title
    }
    
    /// Defines the state for the apply button according to the current profile state and availability to save a new
    fileprivate var applyButtonState: ApplyButtonState {
        guard let profile = parsedProfile else { return .cantParse }
        if profile.isAlreadyStored {
            if profile.isCurrent {
                return .alreadyStored
            }
            return .mayApply
        }
        return .maySave
    }
    
    fileprivate enum ApplyButtonState {
        case cantParse
        case alreadyStored
        case mayApply
        case maySave
        
        var isEnabled: Bool {
            switch self {
            case .cantParse,
                 .alreadyStored: return false
            case .mayApply,
                 .maySave: return true
            }
        }
        
        var title: String {
            switch self {
            case .cantParse: return "Can't parse"
            case .alreadyStored: return "Stored"
            case .mayApply: return "Apply"
            case .maySave: return "Save"
            }
        }
        
    }
    
}

extension ProfileSharingViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        updateApplyButton()
        updateButtons()
    }
    
}
