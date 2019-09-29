//
//  QorumSearchBar.swift
//  Qorum
//
//  Created by Stanislav on 01.02.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

@objc protocol QorumSearchBarDelegate: class {
    
    /// Return false to disallow editing.
    ///
    /// - Parameter searchBar: calling search bar
    /// - Returns: bool value
    @objc optional func searchBarShouldBeginEditing(_ searchBar: QorumSearchBar) -> Bool
    
    /// Called when text changes (including clear)
    ///
    /// - Parameters:
    ///   - searchBar: calling search bar
    ///   - searchText: current text
    @objc optional func searchBar(_ searchBar: QorumSearchBar, textDidChange searchText: String)
    
    /// Сalled when cancel button pressed
    ///
    /// - Parameter searchBar: calling search bar
    @objc optional func searchBarCancelButtonClicked(_ searchBar: QorumSearchBar)
    
    /// Сalled when cancel button pressed
    ///
    /// - Parameter searchBar: calling search bar
    @objc optional func searchBarLocationButtonClicked(_ searchBar: QorumSearchBar)
}

class QorumSearchBar: UIView {
    
    weak var delegate: QorumSearchBarDelegate?
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    /// contained text
    var text: String {
        get {
            return textField?.text ?? ""
        } set {
            textField?.text = newValue
        }
    }
    
    private(set) lazy var contentView: UIView = {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }()
    
    // MARK: - Object lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        addSubview(contentView)
        contentView.snp.makeConstraints { maker in
            maker.top.leading.trailing.bottom.equalTo(0)
        }
        contentView.backgroundColor = .clear
        backgroundColor = UIColor.searchBarBlack
        layer.cornerRadius = 8
        layer.masksToBounds = true
        textField.attributedPlaceholder = NSAttributedString(string: "Search",
                                                             attributes: [.foregroundColor: UIColor(in8bit: 130, 134, 145)])
        textField.delegate = self
    }
    
    // MARK: - Actions
    
    @IBAction func textFieldTextChanged() {
        delegate?.searchBar?(self, textDidChange: textField.text ?? "")
    }
    
    @IBAction func cancel() {
        delegate?.searchBarCancelButtonClicked?(self)
    }
    
    @IBAction func locationTapped() {
        delegate?.searchBarLocationButtonClicked?(self)
    }
    
}

// MARK: - UITextFieldDelegate
extension QorumSearchBar: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return delegate?.searchBarShouldBeginEditing?(self) ?? true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
}
